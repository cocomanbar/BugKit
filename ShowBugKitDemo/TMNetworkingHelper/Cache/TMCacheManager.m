//
//  TMCacheManager.m
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TMCacheManager.h"
#import "TMDiskCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "TMNetworkConfig.h"
#import <UIKit/UIKit.h>

@interface TMCacheManager ()

/* 本地缓存 */
@property (nonatomic, strong)NSCache *memCache;

@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

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
        
        /* 创建磁盘缓存目录 */
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
        
        //磁盘缓存大小和时间
        _cacheTime = 7 * 24 * 60 * 60;
        _diskCapacity = 200 * 1024 * 1024;
        
        //缓存cache对象
        NSString *fullNamespace = @"com.cocomanbar.TMCacheManager.Cache";
        _memCache = [[NSCache alloc] init];
        _memCache.name = fullNamespace;
        
        // 磁盘读写队列，串行队列
        _ioQueue = dispatch_queue_create("com.hackemist.TMCacheManager", DISPATCH_QUEUE_SERIAL);
        
#if TARGET_OS_IPHONE
        // －接收到内存警告通知－清理内存操作 - clearMemory
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        // －应用程序将要终止通知－执行清理磁盘操作 - cleanDisk
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        // - 进入后台通知 － 后台清理磁盘 - backgroundCleanDisk
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
#endif
        
    }
    return self;
}

#pragma mark - Notification

- (void)clearMemory{
    [self.memCache removeAllObjects];
}

- (void)cleanDisk{
    [TMDiskCache cleanDiskWithioQueue:self.ioQueue CompletionBlock:nil];
}

- (void)backgroundCleanDisk{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    [TMDiskCache cleanDiskWithioQueue:self.ioQueue CompletionBlock:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

#pragma mark - 磁盘缓存相关

- (NSString *)getCacheDiretoryPath {
    return _cacheFile;
}

- (float)totalCacheSize {
    return [TMDiskCache dataSizeInDirectory];
}

- (void)clearTotalCache {
    [TMDiskCache cleanDisk];
}

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
    NSString *hash = [self md5:originString];//这个函数可以改内联函数,提高效率
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
    if (error == nil && (data.length > 0)) {
        //缓存到NSCache临时内存(后台数据原封存储)
        [self writeData:responseObject forKey:hash];
        
        //缓存到沙河文件
        [TMDiskCache writeData:data filename:hash];
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
    cacheData = [self readDataWithKey:hash];
    if (cacheData) {
        return cacheData;
    }
    
    /* 再从disk拿 */
    if (!cacheData) {
        cacheData = [TMDiskCache readDataFromFileName:hash];
        if (cacheData){
            /* 刷新时间点 */
            
            /* NSData转json */
            return [NSJSONSerialization JSONObjectWithData:cacheData options:NSJSONReadingMutableContainers error:nil];
        }
    }
    return cacheData;
}

#pragma mark - 下载数据文件相关

- (NSString *)getDownDirectoryPath {
    return _downFile;
}

- (float)totalDownloadDataSize {
    //未实现，可以仿TMDiskCache
    return 0;
}

- (void)clearDownloadData {
    //未实现，可以仿TMDiskCache
}

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
    //[TMDiskCache writeData:data toDir:_downFile filename:fileName];
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
    
    //data = [TMDiskCache readDataFromDir:_downFile filename:fileName];
    
    if (data) {
        NSString *path = [_downFile stringByAppendingPathComponent:fileName];
        fileUrl = [NSURL fileURLWithPath:path];
    }
    
    return fileUrl;
}

#pragma mark - 临时缓存

- (void)writeData:(id)data forKey:(NSString *)key {
    assert(data);
    assert(key);
    [self.memCache setObject:data forKey:key];
}

- (id)readDataWithKey:(NSString *)key {
    assert(key);
    id data = nil;
    data = [self.memCache objectForKey:key];
    return data;
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

#pragma mark - delloc

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
