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
#define address2 @"2282876205@qq.com"


#define GoldPrice @"https://ccsa.ebsnew.boc.cn/shareFinace/shareH5/Framework/index.html?entrance=sharePreciousMetal_preciousMetalDetail&ccygrp=035001&from=singlemessage&isappinstalled=0#1"

@interface GoldPriceVC ()<UIWebViewDelegate,SKPSMTPMessageDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *buyTF;
@property (weak, nonatomic) IBOutlet UITextField *sellTF;

@property (nonatomic,strong)SKPSMTPMessage *myMessage;

@property (nonatomic,assign) CGFloat currentPrice;


@end

@implementation GoldPriceVC

- (SKPSMTPMessage *)myMessage {
//    if (_myMessage == nil) {
    
        SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
        myMessage.fromEmail = @"wzs9658@163.com";
        
        myMessage.toEmail = @"1224708605@qq.com";
        myMessage.bccEmail = @"Goodman@qq.com";
        myMessage.relayHost = @"smtp.163.com";//
        
        myMessage.requiresAuth = YES;
        
        myMessage.delegate = self;
        
        
        if (myMessage.requiresAuth) {
            myMessage.login = @"wzs9658@163.com";
            
            myMessage.pass = @"wzs888888";
            
        }
        
        myMessage.wantsSecure = YES; //为gmail邮箱设置 smtp.gmail.com
        
        myMessage.subject = @"黄金价";
        
        _myMessage = myMessage;
//    }
    return _myMessage;
}

#pragma mark---- 重新请求数据 ----
- (IBAction)resetRequest:(id)sender {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:GoldPrice]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:GoldPrice]]];
}

- (void)scheduledTime
{
    __weak typeof(self) weak_self = self;
    [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weak_self.webView reload];
        NSLog(@"%s",__func__);
    }];
}

#pragma mark - <UIWebViewDelegate>
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    __weak GoldPriceVC *weakSelf =  self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //        NSString *JsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
        //        NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:JsToGetHTMLSource];
        //        NSLog(@"%@",HTMLSource);
        
        
        CGFloat currentPrice = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('referPrice bold colRed')[0].innerHTML"] floatValue];

        [weakSelf judgeWith:currentPrice mailAress:address1];
        
        
    });
}

- (void)judgeWith:(CGFloat)currentPrice mailAress:(NSString *)mailAress{
    
    if (currentPrice >= [self.sellTF.text floatValue] ){
        NSString *str = [NSString stringWithFormat:@"适合卖,当前价格:%f",currentPrice];
        
        [self sendMail:mailAress currentPrice:currentPrice title:str];
        
    } else if (currentPrice <= [self.buyTF.text floatValue]) {
        NSString *str = [NSString stringWithFormat:@"适合买入,当前价格:%f",currentPrice];
        [self sendMail:mailAress currentPrice:currentPrice title:str];
        
    }
    
}

#pragma mark---- 发送邮件 ----
- (void)sendMail:(NSString *)address currentPrice:(CGFloat)currentPrice title:(NSString *)title{
 
    SKPSMTPMessage *myMessage = [self myMessage];
    myMessage.subject = title;

    
    myMessage.toEmail = address;
    currentPrice = currentPrice;
    
    
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
    NSLog(@"恭喜,邮件发送成功");
    
    if ([message.toEmail isEqualToString:address1]) {
        [self judgeWith:self.currentPrice mailAress:address2];
    }
    
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    NSLog(@"不好意思,邮件发送失败");
    
}








@end
