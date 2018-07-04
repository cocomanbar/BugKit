//
//  BugAssistiveHttpHelper.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 通知刷新列表 */
#define kNotifyKeyReloadHttp    @"kNotifyKeyReloadHttp"

@protocol BugAssistiveHttpHelperDelegate <NSObject>
- (NSData *)decryptJson:(NSData *)data;
@end

@interface BugAssistiveHttpHelper : NSObject

+ (instancetype)shareInstance;

/* 获取当前时间戳, 用来做请求标志 */
+ (NSString *)currentTimeFormatter;

/* 设置代理 */
@property (nonatomic, weak)id<BugAssistiveHttpHelperDelegate> delegate;

/* http请求数据是否加密，默认不加密 */
@property (nonatomic, assign)BOOL isHttpRequestEncrypt;

/* http响应数据是否加密，默认不加密 */
@property (nonatomic, assign)BOOL isHttpResponseEncrypt;

/* 设置只抓取的域名，忽略大小写，默认抓取所有 */
@property (nonatomic, strong)NSArray *arrOnlyHosts;

@end
