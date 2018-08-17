//
//  TMNetworkConfig.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/28.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "TMNetworkConfig.h"

@implementation TMNetworkConfig

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static TMNetworkConfig *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _enableDebug = NO;
        _requestTimeout = 30;
        _betaVersion = YES;
        _apiAnalyse = NO;
        
        //举个例子
        //platform/apiVersion/appName/token/guid
        //token、guid、userID等这些公共参数随着退出登录再重新登录而改变的参数专门封装有interface接口修改。
        /*
         _generalParameters = @{@"platform":@"iOS",
                                @"apiVersion":@"1.0",
                                @"appName":@"xxx",
                                @"token":@"从缓存在河沙里拿，拿不到就传空",
                                @"guid":@"从缓存在河沙里拿，拿不到就传空"
                                };
         */
    }
    return self;
}

#pragma mark - interface

/**
 添加公共请求参数
 */
+ (void)addGeneralParameter:(NSString *)sKey value:(id)sValue {
    if (!sKey || !sValue) {
        return;
    }
    TMNetworkConfig *manager = [TMNetworkConfig shareInstance];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    [mDict addEntriesFromDictionary:manager.generalParameters];
    [mDict setValue:sValue forKey:sKey];
    manager.generalParameters = mDict.copy;
}

/**
 移除请求参数
 */
+ (void)removeGeneralParameter:(NSString *)sKey {
    if (!sKey) {
        return;
    }
    TMNetworkConfig *manager = [TMNetworkConfig shareInstance];
    NSMutableDictionary *mDict = manager.generalParameters.mutableCopy;
    if ([mDict.allKeys containsObject:sKey]) {
        [mDict removeObjectForKey:sKey];
    }
    manager.generalParameters = mDict.copy;
}

@end
