//
//  LSLWKWebTestViewController.m
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/19.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import "LSLWKWebTestViewController.h"
#import "LSLWKScriptMessageHandler.h"

static NSString * const kGetUserInfoKey = @"getUserInfo";    // OC调用JS无参
static NSString * const kGotoPaymentKey = @"gotoPayment";    // OC调用JS有参

@interface LSLWKWebTestViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) LSLWKScriptMessageHandler *messageHandle;

@end

@implementation LSLWKWebTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // webView的配置对象对传出数据的名字进行监听，此时负责接收JS消息处理的对象不要忘记履行协议<WKScriptMessageHandler>
    [self.webView.configuration.userContentController addScriptMessageHandler:self.messageHandle name:kGetUserInfoKey];
    [self.webView.configuration.userContentController addScriptMessageHandler:self.messageHandle name:kGotoPaymentKey];
    
    [self loadLocalHtmlWithName:@"index2"];
}

#pragma mark - <WKScriptMessageHandler>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if([message.name isEqualToString:kGetUserInfoKey]) {
        [self getUserInfo];
    } else if ([message.name isEqualToString:kGotoPaymentKey]) {
        [self gotoPayment:message.body];
    }
}

#pragma mark - JS 与 OC 交互

- (void)getUserInfo {
    NSLog(@"JS调用OC成功！");
    // TODO: do something
    [self callUserInfoBack];
}

- (void)callUserInfoBack {
    NSLog(@"OC调用JS方法，并传递参数！");
    
    // OC调用JS有参
    NSString *js = @"callback('OC调用JS方法成功！')";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable objct, NSError * _Nullable error) {
    }];
}

- (void)gotoPayment:(NSString *)orderID {
    if (!orderID || orderID.length <= 0) {
        NSLog(@"商城订单，未获取到订单编号。");
        return;
    }
    NSLog(@"成功获取到JS传递过来的订单编号orderID = %@ ", orderID);
    
    // OC调用JS无参
    NSString *js = @"alerCallback()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable objct, NSError * _Nullable error) {
    }];
}

#pragma mark - <WKUIDelegate>
// 如果不实现以下代理方法，H5中的alert将不会被调起。

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - actions

- (void)dealloc {
    [self.webView.configuration.userContentController removeAllUserScripts];
}

#pragma mark - setter and getter

- (LSLWKScriptMessageHandler *)messageHandle {
    if (!_messageHandle) {
        _messageHandle = [LSLWKScriptMessageHandler scriptWithDelegate:self];
    }
    return _messageHandle;
}

@end
