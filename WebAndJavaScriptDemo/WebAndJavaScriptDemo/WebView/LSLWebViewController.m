//
//  LSLWebViewController.m
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/19.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import "LSLWebViewController.h"

@interface LSLWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *lastUrl;       // 最后加载的一个网页
@property (nonatomic, copy) NSString *htmlString;
@property (nonatomic, copy) NSString *localHtmlName;

@property (nonatomic, strong) UIBarButtonItem *backBtn;
@property (nonatomic, strong) UIBarButtonItem *refreshBtn;
 
@end

@implementation LSLWebViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)initWithUrl:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (instancetype)initWithHtmlString:(NSString *)htmlString {
    if (self = [super init]) {
        _htmlString = [htmlString copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[self.refreshBtn];
    [self setupWebView];
    [self loadWebView];
}

#pragma mark - setup

- (void)setupWebView {
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
    self.navigationItem.rightBarButtonItems = @[self.refreshBtn];
    
    CGRect frame = self.view.bounds;
    frame.origin.y = 64;
    self.webView.frame = frame;
    
    self.progressView.frame = CGRectMake(0, 64, frame.size.width, 5);
}

#pragma mark - <UIWebViewDelegate>

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.navigationItem.title = @"加载中...";
    [self startLoadWebViewRefreshProgressView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.leftBarButtonItems = self.webView.canGoBack ? @[self.backBtn] : nil;
    [self endLoadWebViewRefreshProgressView];
    [self lsl_webViewDidFinishLoad:webView];
}

// 让子类去重写此方法，做自己的事情
- (void)lsl_webViewDidFinishLoad:(UIWebView *)webView {
    // do something
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.lastUrl = webView.request.URL;
    [self endLoadWebViewRefreshProgressView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)startLoadWebViewRefreshProgressView {
    self.progressView.alpha = 1.0;
    [self.progressView setProgress:0.0 animated:NO];
    [UIView animateWithDuration:3.0 animations:^{
        [self.progressView setProgress:0.6 animated:YES];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.progressView setProgress:0.9 animated:YES];
        }];
    }];
}

- (void)endLoadWebViewRefreshProgressView {
    if (self.progressView.progress >= 1.0) {
        self.progressView.alpha = 0.0;
        [self.progressView setProgress:0.0 animated:NO];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.progressView setProgress:1.0 animated:YES];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.01  animations:^{
            self.progressView.alpha = 0.0;
            [self.progressView setProgress:0.0 animated:NO];
        }];
    }];
}

#pragma mark - load

- (void)loadWebView {
    if ([self.lastUrl isKindOfClass:[NSURL class]]) {
        [self loadWithUrl:self.lastUrl];
        
    } else if ([self.url isKindOfClass:[NSURL class]]) {
        [self loadWithUrl:self.url];
        
    } else if(self.htmlString.length > 0) {
        [self loadWebViewWithURLString:self.htmlString];
        
    } else {}
}

- (void)loadWithUrl:(NSURL *)url {
    if ([url isKindOfClass:[NSURL class]]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:5.0];
        [self.webView loadRequest:request];
    }
}

- (void)loadWebViewWithURLString:(NSString *)url {
    if (url.length > 0) {
        self.htmlString = [url copy];
        [self loadWithUrl:[NSURL URLWithString:self.htmlString]];
    }
}

- (void)loadLocalHtmlWithName:(NSString *)name {
    if (!name || name.length <= 0) {
        NSLog(@"本地不存在网页名为：%@的网页。", name);
        return;
    }
    self.localHtmlName = [name copy];
    NSURL *baseURL     = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:name ofType:@"html"];
    NSString *htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:baseURL];
}

#pragma mark - actions

- (void)goBack {
    [self.webView goBack];
}

- (void)goForward {
    [self.webView goForward];
}

- (void)reloadWebView {
    if (self.htmlString.length <=0 && self.url == nil) {
        [self loadLocalHtmlWithName:self.localHtmlName];
    } else {
        [self.webView reload];
    }
}

- (void)goBackWebView {
    if (self.webView.canGoBack) {
        [self goBack];
    } else {
        [self closeWebView];
    }
}

- (void)closeWebView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - setter and getter

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.trackTintColor = [UIColor whiteColor];
        _progressView.backgroundColor = [UIColor whiteColor];
        _progressView.progressTintColor = [UIColor blueColor];
    }
    return _progressView;
}

- (UIBarButtonItem *)backBtn {
    _backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(goBackWebView)];
    return _backBtn;
}

- (UIBarButtonItem *)refreshBtn {
    _refreshBtn = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(reloadWebView)];
    return _refreshBtn;
}

@end
