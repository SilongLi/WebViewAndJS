//
//  LSLWKWebViewController.m
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/19.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import "LSLWKWebViewController.h"


static NSString *const kProgressKey = @"estimatedProgress";

@interface LSLWKWebViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebViewConfiguration *config;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *lastUrl;       // 最后加载的一个网页
@property (nonatomic, copy) NSString *localHtmlName;

@property (nonatomic, strong) UIBarButtonItem *backBtn;
@property (nonatomic, strong) UIBarButtonItem *refreshBtn;

@end

@implementation LSLWKWebViewController

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
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self setupWebView];
    [self loadWebView];
}

#pragma mark - setup

- (void)setupWebView {
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
    [self updateWebViewLayout];
}

- (void)updateWebViewLayout {
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
    self.navigationItem.rightBarButtonItems = @[self.refreshBtn];
    
    CGRect frame = self.view.bounds;
    frame.origin.y = 64;
    self.webView.frame = frame;
    self.progressView.frame = CGRectMake(0, 64, frame.size.width, 5);
}
#pragma mark - <WKNavigationDelegate>

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.navigationItem.title = @"在加载...";
    self.progressView.alpha = 1.0;
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.navigationItem.title = webView.title;
    self.navigationItem.leftBarButtonItems  = self.webView.canGoBack ? @[self.backBtn] : nil;
    self.navigationItem.rightBarButtonItems = @[self.refreshBtn];
    
    [self.tabBarController.tabBar setHidden:self.webView.canGoBack];
    [self updateWebViewLayout];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.progressView.alpha = 0.0;
    }];
    
    [self lsl_WebView:webView didFinishNavigation:navigation];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [UIView animateWithDuration:0.5 animations:^{
        self.progressView.alpha = 0.0;
    }];
    self.lastUrl = webView.URL;
    [self.tabBarController.tabBar setHidden:NO];
    [self updateWebViewLayout];
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    BOOL allow = [self webView:webView decidePolicyForNavigationAction:navigationAction];
    allow ? decisionHandler(WKNavigationActionPolicyAllow) : decisionHandler(WKNavigationActionPolicyCancel);
}

- (BOOL)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction {
    // 子类不可重写父类的webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler方法，如需实现拦截请调用此方法实现.
    return YES;
}

// 页面加载完成之后调用，做一些额外的操作
- (void)lsl_WebView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 做自己的事情
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kProgressKey]) {
        self.progressView.progress = self.webView.estimatedProgress;
    }
}

#pragma mark - setter and getter

- (WKWebViewConfiguration *)config {
    if (!_config) {
        _config = [[WKWebViewConfiguration alloc] init];
        _config.preferences = [[WKPreferences alloc] init];
        _config.preferences.minimumFontSize = 10;
        _config.preferences.javaScriptEnabled = YES;
        _config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    }
    return _config;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.config];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        [_webView addObserver:self forKeyPath:kProgressKey options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
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

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:kProgressKey];
    [self.webView.configuration.userContentController removeAllUserScripts];
}


@end
