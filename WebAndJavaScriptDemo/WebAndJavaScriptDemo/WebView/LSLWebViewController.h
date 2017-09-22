//
//  LSLWebViewController.h
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/19.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSLWebViewController : UIViewController 

- (instancetype)initWithUrl:(NSURL *)url;
- (instancetype)initWithHtmlString:(NSString *)htmlString;

- (void)loadWebViewWithURLString:(NSString *)url;

// 加载本地网页， Name: 网页名称
- (void)loadLocalHtmlWithName:(NSString *)name;

- (void)goBack;
- (void)goForward;
- (void)loadWebView;

// 做自己的事情
- (void)lsl_webViewDidFinishLoad:(UIWebView *)webView;

@end
