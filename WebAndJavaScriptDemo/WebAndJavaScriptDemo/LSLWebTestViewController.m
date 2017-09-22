//
//  LSLWebTestViewController.m
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/19.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import "LSLWebTestViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSObjcDelegate <JSExport>
// JS调用OC无参
- (void)getUserInfo;
// JS调用OC有参
- (void)gotoPayment:(NSString *)orderID;
@end


@interface LSLWebTestViewController () <JSObjcDelegate>
@property (nonatomic, strong) JSContext *jsContext;
@end

@implementation LSLWebTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLocalHtmlWithName:@"index"];
}

#pragma mark - <UIWebViewDelegate>

- (void)lsl_webViewDidFinishLoad:(UIWebView *)webView {
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"shopping"] = self;
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
}

#pragma mark - <JSObjcDelegate>

- (void)getUserInfo {
    NSLog(@"JS调用OC成功！");
    // TODO: do something
    [self callUserInfoBack];
}

- (void)callUserInfoBack {
    NSLog(@"OC调用JS方法，并传递参数！");
    
    // OC调用JS有参
    JSValue *Callback = self.jsContext[@"callback"];
    [Callback callWithArguments:@[@"OC调用JS方法成功！"]];
}

- (void)gotoPayment:(NSString *)orderID {
    if (!orderID || orderID.length <= 0) {
        NSLog(@"商城订单，未获取到订单编号。");
        return;
    }
    NSLog(@"成功获取到JS传递过来的订单编号orderID = %@ ", orderID);
    
    // OC调用JS无参
    JSValue *Callback = self.jsContext[@"alerCallback"];
    [Callback callWithArguments:nil];
}

@end
