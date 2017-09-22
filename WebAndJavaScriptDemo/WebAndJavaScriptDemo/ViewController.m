//
//  ViewController.m
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/19.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import "ViewController.h"
#import "LSLWebTestViewController.h"
#import "LSLWKWebTestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad]; 
}

- (IBAction)UIWebViewAndJSButtonClicked:(UIButton *)sender {
    LSLWebTestViewController *webVC = [[LSLWebTestViewController alloc] init];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)WKWebVeiwAndJSButtonClicked:(UIButton *)sender {
    LSLWKWebTestViewController *webVC = [[LSLWKWebTestViewController alloc] init];
    [self.navigationController pushViewController:webVC animated:YES];
}


@end
