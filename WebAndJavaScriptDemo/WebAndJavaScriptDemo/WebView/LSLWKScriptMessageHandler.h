//
//  LSLWKScriptMessageHandler.h
//  WebAndJavaScriptDemo
//
//  Created by lisilong on 17/9/21.
//  Copyright © 2017年 LongShaoDream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface LSLWKScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property (nullable, nonatomic, weak)id <WKScriptMessageHandler> delegate;

/** 创建方法 */
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;

/** 便利构造器 */
+ (instancetype)scriptWithDelegate:(id<WKScriptMessageHandler>)delegate;;



@end
