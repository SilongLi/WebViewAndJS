//
//  LSLWKScriptMessageHandler.m
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/21.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import "LSLWKScriptMessageHandler.h"

@implementation LSLWKScriptMessageHandler

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

+ (instancetype)scriptWithDelegate:(id<WKScriptMessageHandler>)delegate {
    return [[LSLWKScriptMessageHandler alloc] initWithDelegate:delegate];
}

#pragma mark - <WKScriptMessageHandler>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
