//
//  TMMemoryCache.m
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TMMemoryCache.h"
#import <UIKit/UIKit.h>

static NSCache *_shareCache;

@implementation TMMemoryCache

+ (NSCache *)shareCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareCache = [[NSCache alloc] init];
    });
    return _shareCache;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //当收到内存警报时，清空内存缓存
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [_shareCache removeAllObjects];
        }];
    }
    return self;
}

+ (void)writeData:(id)data forKey:(NSString *)key {
    assert(data);
    assert(key);
    NSCache *cache = [TMMemoryCache shareCache];
    [cache setObject:data forKey:key];
    
}

+ (id)readDataWithKey:(NSString *)key {
    assert(key);
    id data = nil;
    NSCache *cache = [TMMemoryCache shareCache];
    data = [cache objectForKey:key];
    return data;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end
