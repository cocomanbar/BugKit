//
//  TMNetworkConfig.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/28.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMNetworkConfig : NSObject

+ (_Nonnull instancetype)shareInstance;

/* 是否是测试环境API,默认是YES */
@property (nonatomic, assign)BOOL betaVersion;

/* 是否为调试模式（默认 false, 当为 true 时，会输出 网络请求日志） */
@property (nonatomic, readwrite) BOOL enableDebug;

/* 是否开启ipa调用分析收集, 暂用到本地内存空间, 一般是下次登录时静态上传后清空, 默认为NO */
@property (nonatomic, assign)BOOL apiAnalyse;

/* 生产服务器地址 默认： */
@property (nonatomic, copy, readwrite, nonnull) NSString *proServerAPI;

/* 测试服务器地址 默认： */
@property (nonatomic, copy, readwrite, nonnull) NSString *testServerAPI;

/* 公共参数, 例如 platform/apiVersion/language/appName/token/guid */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *generalParameters;

/* 公共请求头 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *generalHeaders;

/* 请求默认时间, 默认30秒 */
@property (nonatomic, assign)NSInteger requestTimeout;

/* 内存缓存时间, 默认是7天, 一旦设定不能轻易更改, 注意赋值方法 */
@property (nonatomic, assign)NSTimeInterval cacheTime;

/* 内存缓存阈值, 默认是200M, 一旦设定不能轻易更改, 注意赋值方法 */
@property (nonatomic, assign)NSInteger diskValue;

/**
 添加公共请求参数
 */
+ (void)addGeneralParameter:(NSString * _Nonnull)sKey value:(id _Nonnull )sValue;

/**
 移除请求参数
 */
+ (void)removeGeneralParameter:(NSString * _Nonnull)sKey;

@end
