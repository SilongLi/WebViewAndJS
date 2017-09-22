//
//  LSLWKWebViewController.h
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/19.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LSLWKWebViewController : UIViewController

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *htmlString;  

- (instancetype)initWithUrl:(NSURL *)url;
- (instancetype)initWithHtmlString:(NSString *)htmlString;

- (void)loadWebViewWithURLString:(NSString *)url;

// 加载本地网页， Name: 网页名称
- (void)loadLocalHtmlWithName:(NSString *)name;

- (void)goBack;
- (void)goForward;
- (void)loadWebView;


// 子类不可重写父类的webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler方法，如需实现拦截请调用此方法实现.
- (BOOL)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction;


// 页面加载完成之后调用
- (void)lsl_WebView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;


@end
