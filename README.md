# WebViewAndJS
> UIWebView和WKWebView与JavaScript的交互方式

## 一、介绍
> 苹果在iOS2推出了UIWebView，用于移动端加载网页等资源。但是它从设计之初就比较笨重，存在占用内存过多，交互各种限制等问题。所以在iOS8.0之后，苹果对UIWebView进行优化和重造，推出了WKWebView用于取代UIWebView。

## 二、大纲
- WKWebView对比UIWebView的性能优势；
- WKWebView加载本地html网页的优雅方式；
- UIWebView的封装使用；
- WKWebView的封装使用；
- UIWebView与JS交互;
- WKWebView与JS交互； 

## 三、详解
### 1、相对于UIWebView，WKWebView有以下的改进：
- 在性能、稳定性、功能方面有很大提升，直观体现是内存占用更少；
- 允许JavaScript的Nitro库加载并使用（UIWebView中限制）；
- 支持了更多的HTML5特性；
- 高达60fps的滚动刷新率以及内置手势；
- 将UIWebViewDelegate与UIWebView重构成了14类与3个协议（详见SDK）；
- 开放了一些重要的属性，比如加载进度条（estimatedProgress）等。

### 2、WKWebView加载本地html网页的优雅方式

```objc
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
```

### 3、UIWebView封装使用看源码
### 4、WKWebView的封装使用看源码
#### (1) 加载的状态回调 （WKNavigationDelegate）
- 用来追踪加载过程（页面开始加载、加载完成、加载失败）的方法：

```objc
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
```
- 页面跳转的代理方法：

```objc
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
```
#### （2）新增的WKUIDelegate协议
- 主要用于WKWebView处理web界面的三种提示框(警告框、确认框、输入框)**如果不实现这些代理方法，H5中的alert将不会被调起。**

```objc
// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    // TODO: do something
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
   // TODO: do something
}
```

### 5、UIWebView与JS交互
**UIWebView 使用的 JavaScriptCore 框架，交互时为 JavaScript 运行的上下文环境 JSContext 注入对象 Bridge；WKWebView 使用的 WebKit 框架，交互时为 webkit.messageHandlers 注入对象。**

```objc
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
// 其中“shopping”为与JS交互的对象
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
```

### 6、WKWebview与JS交互
> WKWebview不需要借助JavaScriptCore或者webJavaScriptBridge，它是通过WKUserContentController实现js native的交互。简单的说就是先注册约定好的方法，然后再调用。

- 注意点：
	- 使用WKScriptMessageHandler时，最好创建一个代理对象，然后通过代理对象回调指定的self，防止内存泄露；
	- 如果使用了addScriptMessageHandler，要在的dealloc中释放一下否则会造成内存泄漏。

#### WKWebView里面注册供JS调用的方法
- 通过WKUserContentController提供的以下方法，实现注册：

```objc
/** name：表示JS调用的OC方法名称； scriptMessageHandler：是接受事件处理的对象。 */
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
```

- JS在调用OC注册方法的时候要用下面的方式

```objc
window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
```

- 实现如下：

```objc
static NSString *const kGetUserInfoKey = @"getUserInfo";    // OC调用JS无参
static NSString *const kGotoPaymentKey = @"gotoPayment";    // OC调用JS有参

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
```

### 具体的实现请查阅demo