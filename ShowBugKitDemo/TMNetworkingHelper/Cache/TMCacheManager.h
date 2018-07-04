//
//  TMCacheManager.h
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMCacheManager : NSObject

#pragma mark -

/**
 默认的磁盘空间是200MB，缓存有效期是7天
 
 @return shareManager
 */
+ (TMCacheManager *)shareManager;

#pragma mark -

/* Json数据缓存路径, 默认是 */
@property (nonatomic, copy, readonly)NSString *cacheFile;

/* 数据下载文件缓存路径, 默认是 */
@property (nonatomic, copy, readonly)NSString *downFile;

#pragma mark -

/**
 *  缓存响应数据-只对Json数据字典形式做缓存
 *  时下公司接口逻辑, 如需要改变, 可以在缓存模块修改相关代码
 *
 *  @param responseObject 响应数据
 *  @param requestUrl     请求url
 *  @param params         请求参数
 */
- (void)cacheResponseObject:(id)responseObject requestUrl:(NSString *)requestUrl params:(NSDictionary *)params;

/**
 *  获取响应数据
 *
 *  @param requestUrl 请求url
 *  @param params     请求参数
 *
 *  @return 响应数据
 */
- (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl params:(NSDictionary *)params;

/**
 *  存储下载文件
 *
 *  @param data       文件数据
 *  @param requestUrl 请求url
 */
- (void)storeDownloadData:(NSData *)data
               requestUrl:(NSString *)requestUrl;

/**
 *  获取磁盘中的下载文件
 *
 *  @param requestUrl 请求url
 *
 *  @return 文件本地存储路径
 */
- (NSURL *)getDownloadDataFromCacheWithRequestUrl:(NSString *)requestUrl;

/**
 *  获取缓存目录路径
 *
 *  @return 缓存目录路径
 */
- (NSString *)getCacheDiretoryPath;

/**
 *  获取下载目录路径
 *
 *  @return 下载目录路径
 */
- (NSString *)getDownDirectoryPath;

/**
 *  获取缓存大小
 *
 *  @return 缓存大小
 */
- (NSUInteger)totalCacheSize;

/**
 *  清除所有缓存
 */
- (void)clearTotalCache;

/**
 *  清除最近最少使用的缓存，用LRU算法实现
 */
- (void)clearLRUCache;

/**
 *  获取所有下载数据大小
 *
 *  @return 下载数据大小
 */
- (NSUInteger)totalDownloadDataSize;

/**
 *  清除下载数据
 */
- (void)clearDownloadData;

@end
































