//
//  TMDiskCache.m
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TMDiskCache.h"
#import "TMCacheManager.h"

@implementation TMDiskCache

+ (void)writeData:(id)data filename:(NSString *)filename{
    assert(data);
    assert(filename);
    
    NSString *filePath = [[[TMCacheManager shareManager] getCacheDiretoryPath] stringByAppendingPathComponent:filename];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
}

+ (id)readDataFromFileName:(NSString *)filename {
    assert(filename);
    NSData *data = nil;
    NSString *filePath = [[[TMCacheManager shareManager] getCacheDiretoryPath] stringByAppendingPathComponent:filename];
    data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    return data;
}

+ (float)dataSizeInDirectory {
    
    NSString *directory = [[TMCacheManager shareManager] getCacheDiretoryPath];
    float _total = 0.0;
    NSError *error = nil;
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    if (!error && array.count) {
        for (NSString *subFile in array) {
            NSString *filePath = [directory stringByAppendingPathComponent:subFile];
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            _total += [attributes[NSFileSize] unsignedIntegerValue];
        }
    }
    return _total;
}

+ (void)cleanDiskWithioQueue:(dispatch_queue_t)ioQueue CompletionBlock:(void(^)(void))completionBlock{
    dispatch_async(ioQueue, ^{
        NSString *directory = [[TMCacheManager shareManager] getCacheDiretoryPath];
        NSURL *diskCacheURL = [NSURL fileURLWithPath:directory isDirectory:YES];
        NSArray *resourceKeys = @[NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        
        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        // 计算过期日期
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:- [[TMCacheManager shareManager] cacheTime]];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        // 遍历缓存路径中的所有文件，此循环要实现两个目的
        //
        //  1. Removing files that are older than the expiration date.
        //     删除早于过期日期的文件
        //  2. Storing file attributes for the size-based cleanup pass.
        //     保存文件属性以计算磁盘缓存占用空间
        //
        
        NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            // Remove files that are older than the expiration date; 记录要删除的过期文件
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [urlsToDelete addObject:fileURL];
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            // 保存文件引用，以计算总大小
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        // 删除过期的文件
        for (NSURL *fileURL in urlsToDelete) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        }
        
        // 如果剩余磁盘缓存空间超出最大限额，再次执行清理操作，删除最早的文件
        NSInteger diskCapacity = [[TMCacheManager shareManager] diskCapacity];
        if (diskCapacity > 0 && currentCacheSize > diskCapacity) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = diskCapacity / 2;
            
            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            
            // Delete files until we fall below our desired cache size.
            // 循环依次删除文件，直到低于期望的缓存限额
            for (NSURL *fileURL in sortedFiles) {
                if ([[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

//清除磁盘文件下的所有子文件
+ (void)cleanDisk {
    NSError *error = nil;
    NSString *directory = [[TMCacheManager shareManager] getCacheDiretoryPath];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    if (!error && array.count) {
        for (NSString *subFile in array) {
            NSString *filePath = [directory stringByAppendingPathComponent:subFile];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

@end
