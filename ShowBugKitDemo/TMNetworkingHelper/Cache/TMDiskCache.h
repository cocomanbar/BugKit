//
//  TMDiskCache.h
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//  仅仅是磁盘缓存（不包括下载文件）

#import <Foundation/Foundation.h>

@interface TMDiskCache : NSObject

/**
 *  将数据写入磁盘
 *
 *  @param data      数据
 *  @param filename  文件名
 */
+ (void)writeData:(id)data filename:(NSString *)filename;

/**
 *  从磁盘读取数据
 *
 *  @param filename  文件名
 *
 *  @return 数据
 */
+ (id)readDataFromFileName:(NSString *)filename;

/**
 *  获取目录中文件总大小
 *
 *  @return 文件总大小
 */
+ (float)dataSizeInDirectory;

/**
 *  清理过期文件
 *
 *  @param completionBlock 回调可选
 */
+ (void)cleanDiskWithioQueue:(dispatch_queue_t)ioQueue CompletionBlock:(void(^)(void))completionBlock;

/**
 *  删除总目录文件 - 用于升级后清理掉全部文件，有接口修改升级的可能。
 */
+ (void)cleanDisk;

@end
