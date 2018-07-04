//
//  TMCacheManager.m
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TMCacheManager.h"
#import "TMMemoryCache.h"
#import "TMDiskCache.h"
#import "TMLRUManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "TMNetworkConfig.h"

static NSUInteger _diskCapacity;
static NSTimeInterval _cacheTime;

@implementation TMCacheManager

#pragma mark - 初始化

+ (TMCacheManager *)shareManager {
    static TMCacheManager *_cacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheManager = [[TMCacheManager alloc] init];
    });
    return _cacheManager;
}

- (instancetype)init{
    if (self = [super init]) {
        
        _cacheFile = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
                      stringByAppendingPathComponent:@"TMNetworkResponseFile"];
        _downFile =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
                      stringByAppendingPathComponent:@"TMNetworkDownFile"];
        
        /* 创建缓存目录 */
        if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheFile]) {
            BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:_cacheFile
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil];
            if (!ret) {
                [[NSFileManager defaultManager] createDirectoryAtPath:_cacheFile
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
        }
        /* 下载文件缓存目录 */
        if (![[NSFileManager defaultManager] fileExistsAtPath:_downFile]) {
            BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:_downFile
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil];
            if (!ret) {
                [[NSFileManager defaultManager] createDirectoryAtPath:_downFile
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
        }
        
        _diskCapacity = [TMNetworkConfig shareInstance].diskValue;
        _cacheTime = [TMNetworkConfig shareInstance].cacheTime;
    }
    return self;
}


#pragma mark - 存/取 返回数据

- (void)cacheResponseObject:(id)responseObject
                 requestUrl:(NSString *)requestUrl
                     params:(NSDictionary *)params {
    assert(responseObject);
    assert(requestUrl);
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error == nil && (data.length > 0)) {
        //缓存到NSCache临时内存(后台数据原封存储)
        [TMMemoryCache writeData:responseObject forKey:hash];
        
        //缓存到沙河cache文件
        [TMDiskCache writeData:data toDir:_cacheFile filename:hash];
        [[TMLRUManager shareManager] addFileNode:hash];
    }
}

- (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl
                                    params:(NSDictionary *)params {
    assert(requestUrl);
    
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    id cacheData = nil;
    /* 先从内存拿 */
    cacheData = [TMMemoryCache readDataWithKey:hash];
    if (cacheData) {
        return cacheData;
    }
    
    /* 再从disk拿 */
    if (!cacheData) {
        cacheData = [TMDiskCache readDataFromDir:_cacheFile filename:hash];
        if (cacheData){
            /* 刷新时间点 */
            [[TMLRUManager shareManager] refreshIndexOfFileNode:hash];
            /* NSData转json */
            NSDictionary *cacheDict = [NSJSONSerialization JSONObjectWithData:cacheData options:NSJSONReadingMutableContainers error:nil];
            if (cacheDict) {
                return cacheDict;
            }else{
                return nil;
            }
        }
    }
    return cacheData;
}

#pragma mark - 存/取 下载数据

- (void)storeDownloadData:(NSData *)data
               requestUrl:(NSString *)requestUrl {
    assert(data);
    assert(requestUrl);
    
    NSString *fileName = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    
    strArray = [requestUrl componentsSeparatedByString:@"."];
    if (strArray.count > 0) {
        type = strArray[strArray.count - 1];
    }
    
    if (type) {
        fileName = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        fileName = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    [TMDiskCache writeData:data toDir:_downFile filename:fileName];
}

- (NSURL *)getDownloadDataFromCacheWithRequestUrl:(NSString *)requestUrl {
    assert(requestUrl);
    
    NSData *data = nil;
    NSString *fileName = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    NSURL *fileUrl = nil;
    
    strArray = [requestUrl componentsSeparatedByString:@"."];
    if (strArray.count > 0) {
        type = strArray[strArray.count - 1];
    }
    
    if (type) {
        fileName = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        fileName = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    
    data = [TMDiskCache readDataFromDir:_downFile filename:fileName];
    
    if (data) {
        NSString *path = [_downFile stringByAppendingPathComponent:fileName];
        fileUrl = [NSURL fileURLWithPath:path];
    }
    
    return fileUrl;
}

#pragma mark - 路径文件

- (NSString *)getCacheDiretoryPath {
    return _cacheFile;
}

- (NSString *)getDownDirectoryPath {
    return _downFile;
}

#pragma mark - 大小计算

- (NSUInteger)totalCacheSize {
    return [TMDiskCache dataSizeInDir:_cacheFile];
}

- (NSUInteger)totalDownloadDataSize {
    return [TMDiskCache dataSizeInDir:_downFile];
}

- (void)clearDownloadData {
    [TMDiskCache clearDataIinDir:_downFile];
}

#pragma mark - 清除缓存

- (void)clearTotalCache {
    [TMDiskCache clearDataIinDir:_cacheFile];
}

- (void)clearLRUCache {
    if ([self totalCacheSize] > _diskCapacity) {
        NSArray *deleteFiles = [[TMLRUManager shareManager] removeLRUFileNodeWithCacheTime:_cacheTime];
        NSString *directoryPath = _cacheFile;
        if (directoryPath && deleteFiles.count > 0) {
            [deleteFiles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *filePath = [directoryPath stringByAppendingPathComponent:obj];
                [TMDiskCache deleteCache:filePath];
            }];
            
        }
    }
}

#pragma mark - 散列值

- (NSString *)md5:(NSString *)string {
    if (string == nil || string.length == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH],i;
    
    CC_MD5([string UTF8String],(int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding],digest);
    
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x",(int)(digest[i])];
    }
    
    return [ms copy];
}

@end
