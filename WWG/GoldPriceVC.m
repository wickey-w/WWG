//
//  GoldPriceVC.m
//  WWG
//
//  Created by 王世成 on 2018/7/24.
//  Copyright © 2018年 WSC. All rights reserved.
//

#import "GoldPriceVC.h"

#define GoldPrice @"https://ccsa.ebsnew.boc.cn/shareFinace/shareH5/Framework/index.html?entrance=sharePreciousMetal_preciousMetalDetail&ccygrp=035001&from=singlemessage&isappinstalled=0#1"

@interface GoldPriceVC ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation GoldPriceVC

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
    NSString *JsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:JsToGetHTMLSource];
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *currentPrice = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('referPrice bold colRed')[0].innerHTML"];
    NSLog(@"title:%@,currentPrice:%@",title,currentPrice);
}


@end
