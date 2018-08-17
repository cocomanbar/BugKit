//
//  TMCacheManager.h
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//  缓存模块总入口

#import <Foundation/Foundation.h>

@interface TMCacheManager : NSObject

#pragma mark -

/**
 默认的磁盘空间是200MB，缓存有效期是7天，由TMNetworkConfig配置
 
 @return shareManager
 */
+ (TMCacheManager *)shareManager;

/* 磁盘缓存时间, 默认是7天 */
@property (nonatomic, assign)NSTimeInterval cacheTime;

/* 磁盘缓存阈值, 默认是200M */
@property (nonatomic, assign)NSInteger diskCapacity;

#pragma mark - 文件路径

/* Json数据缓存路径, 默认是 */
@property (nonatomic, copy, readonly)NSString *cacheFile;

/* 数据下载文件缓存路径, 默认是 */
@property (nonatomic, copy, readonly)NSString *downFile;

#pragma mark - 普通json文件存储

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
 *  从缓存中拿出-cache-disk
 *
 *  @param requestUrl 请求url
 *  @param params     请求参数
 *
 *  @return 响应数据
 */
- (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl params:(NSDictionary *)params;


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
 *  获取磁盘缓存大小
 *
 *  @return 缓存大小
 */
- (float)totalCacheSize;

/**
 *  清除所有磁盘缓存
 */
- (void)clearTotalCache;


#pragma mark - 普通下载文件存储 - 缓存没有做好 2018/08/17

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
 *  获取所有下载数据大小
 *
 *  @return 下载数据大小
 */
- (float)totalDownloadDataSize;

/**
 *  清除下载数据
 */
- (void)clearDownloadData;

@end
































