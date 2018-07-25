//
//  GoldPriceVC.m
//  WWG
//
//  Created by 王世成 on 2018/7/24.
//  Copyright © 2018年 WSC. All rights reserved.
//

#import "GoldPriceVC.h"

#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"


#define address1 @"1224708605@qq.com"
//#define address2 @"2282876205@qq.com"
#define WSC_Email @"2384321689@qq.com"
//#define address1 @"wzs9658@163.com"
#define address2 @"496500113@qq.com"

#define sendAddress @"wzs9658@163.com"
#define sendPassword @"wzs888888"



#define GoldPrice @"https://ccsa.ebsnew.boc.cn/shareFinace/shareH5/Framework/index.html?entrance=sharePreciousMetal_preciousMetalDetail&ccygrp=035001&from=singlemessage&isappinstalled=0#1"

@interface GoldPriceVC ()<UIWebViewDelegate,SKPSMTPMessageDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *buyTF;
@property (weak, nonatomic) IBOutlet UITextField *sellTF;
@property (weak, nonatomic) IBOutlet UITextField *tipTF;

@property (nonatomic,strong)SKPSMTPMessage *myMessage;

@property (nonatomic,assign) CGFloat currentPrice;
@property (nonatomic,assign) BOOL isStop;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSMutableArray *priceArray;
@property(nonatomic,strong)NSDate *date;
@property (nonatomic,assign) CGFloat handBuyP;
@property (nonatomic,assign) CGFloat handSellP;
@end

@implementation GoldPriceVC

- (SKPSMTPMessage *)myMessage {
//    if (_myMessage == nil) {
    
        SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
        
        myMessage.toEmail = @"1224708605@qq.com";
        myMessage.bccEmail = @"418496179@qq.com";
        myMessage.relayHost = @"smtp.163.com";//

    
//    myMessage.bccEmail = @"smtp.163.com";
//    myMessage.relayHost = @"Goodman@qq.com";//
    
        myMessage.requiresAuth = YES;
        
        myMessage.delegate = self;
        
        
        if (myMessage.requiresAuth) {
            myMessage.pass = @"wzs888888";
            myMessage.login = sendAddress;
            myMessage.pass = sendPassword;
        }
        
        myMessage.wantsSecure = YES; //为gmail邮箱设置 smtp.gmail.com
        
        myMessage.subject = @"黄金价";
        
        _myMessage = myMessage;
//    }
    return _myMessage;
}

#pragma mark---- 重新请求数据 ----
- (IBAction)resetRequest:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [sender setTitle:sender.selected?@"重新刷新":@"暂停刷新" forState:UIControlStateNormal];
    _isStop = sender.selected;
    if (!_isStop) {
        [self scheduledTime];
    }else {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.priceArray = [NSMutableArray array];
    _buyTF.delegate = self;
    _sellTF.delegate = self;
    _handSellP = [_sellTF.text floatValue];
    _handBuyP = [_buyTF.text floatValue];
    
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:GoldPrice]]];
    [self scheduledTime];
}

- (void)scheduledTime
{
    __weak typeof(self) weak_self = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weak_self.webView reload];
    }];
}

#pragma mark - <UIWebViewDelegate>
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    __weak GoldPriceVC *weakSelf =  self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat currentPrice = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('referPrice bold colRed')[0].innerHTML"] floatValue];
        NSLog(@"%s currentPrice:%.2f",__func__,currentPrice);
        CGFloat averagePrice = 0;
        if (currentPrice) {
            [self.priceArray addObject:[NSNumber numberWithFloat:currentPrice]];
            if (self.priceArray.count > 6) {
                [self.priceArray removeObjectAtIndex:0];
                CGFloat total = 0;
                for (NSNumber *num in self.priceArray) {
                    total += [num floatValue];
                }
                averagePrice = total/self.priceArray.count;
                NSLog(@"%s averagePrice:%.2f",__func__,averagePrice);
            }
        }
        if (!weakSelf.isStop && averagePrice) {
            [weakSelf judgeWith:averagePrice mailAress:WSC_Email];
        }
    });
}

- (void)judgeWith:(CGFloat)currentPrice mailAress:(NSString *)mailAress
{
    if (currentPrice >= [self.sellTF.text floatValue] ){
        NSString *str = [NSString stringWithFormat:@"适合卖,一分钟内平均价格:%f",currentPrice];
        _sellTF.text = [NSString stringWithFormat:@"%.2f",[self.sellTF.text floatValue]+[_tipTF.text floatValue]];
        _date = [NSDate date];
        [self sendMail:mailAress currentPrice:currentPrice title:str];
        
    } else if (currentPrice <= [self.buyTF.text floatValue]) {
        NSString *str = [NSString stringWithFormat:@"适合买入,一分钟内平均价格:%f",currentPrice];
        _buyTF.text = [NSString stringWithFormat:@"%.2f",[self.buyTF.text floatValue]-[_tipTF.text floatValue]];
        _date = [NSDate date];
        [self sendMail:mailAress currentPrice:currentPrice title:str];
    } else if ([[NSDate date] timeIntervalSinceDate:_date] >= 30*60) {
        if (currentPrice > _handSellP && currentPrice < [self.sellTF.text floatValue]) {
            _sellTF.text = [NSString stringWithFormat:@"%.2f",[self.sellTF.text floatValue]-[_tipTF.text floatValue]];
        }else if (currentPrice > _handBuyP && currentPrice > [self.buyTF.text floatValue]) {
            _buyTF.text = [NSString stringWithFormat:@"%.2f",[self.buyTF.text floatValue]+[_tipTF.text floatValue]];
        }
    }
    
}

#pragma mark---- 发送邮件 ----
- (void)sendMail:(NSString *)address currentPrice:(CGFloat)currentPrice title:(NSString *)title{
 
    SKPSMTPMessage *myMessage = [self myMessage];
    myMessage.subject = title;

    
    myMessage.toEmail = address;
    self.currentPrice = currentPrice;
    
    
    //设置邮件内容
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain; charset=UTF-8",kSKPSMTPPartContentTypeKey,
                               title,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    
    myMessage.parts = [NSArray arrayWithObjects:plainPart,nil];
    
    __weak SKPSMTPMessage *weakM =  myMessage;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakM send];
    });
    
    
}


#pragma mark---- SKPSMTPMessageDelegate ----
- (void)messageSent:(SKPSMTPMessage *)message
{
    NSLog(@"恭喜,邮件发送成功 快快快看");
    
//    if ([message.toEmail isEqualToString:address1]) {
//        [self judgeWith:self.currentPrice mailAress:address2];
//    }
    
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    NSLog(@"不好意思,邮件发送失败");
    
}

- (IBAction)buyButtonAction:(UIButton *)sender
{
    _buyTF.text = @"0";
    _handBuyP = 0;
}

- (IBAction)saleButtonAction:(UIButton *)sender
{
    _sellTF.text = @"300";
    _handSellP = 300;
}


#pragma mark - <UITextFieldDelegate>
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _sellTF) {
        _handSellP = [textField.text floatValue];
    }else if (textField == _buyTF) {
        _handBuyP = [textField.text floatValue];
    }
}


@end
