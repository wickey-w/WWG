//
//  ViewController.m
//  WWG
//
//  Created by 王世成 on 2018/7/24.
//  Copyright © 2018年 WSC. All rights reserved.
//

#import "ViewController.h"
#import "GoldPriceVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (IBAction)nextPageAction:(UIButton *)sender
{
    GoldPriceVC *VC = [[GoldPriceVC alloc] init];
    [self presentViewController:VC animated:YES completion:nil];
}

@end
