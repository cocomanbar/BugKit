//
//  TMLRUManager.m
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TMLRUManager.h"

static TMLRUManager *_manager = nil;
static NSMutableArray *_operationQueue = nil;

#define kTMLRUManagerNameFile [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"TMLRUManagerName"]
#define kTMLRUManagerNamePlist [NSString stringWithFormat:@"%@%@",kTMLRUManagerNameFile,@"/TMLRUManagerName.plist"]

@implementation TMLRUManager

+ (TMLRUManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[TMLRUManager alloc] init];
    });
    return _manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        /* 创建文件夹 */
        if (![[NSFileManager defaultManager] fileExistsAtPath:kTMLRUManagerNameFile]) {
            BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:kTMLRUManagerNameFile
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil];
            if (!ret) {
                [[NSFileManager defaultManager] createDirectoryAtPath:kTMLRUManagerNameFile
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
        }
        /* 取plist数据转数组, 数组装的是dict */
        if (![[NSFileManager defaultManager] fileExistsAtPath:kTMLRUManagerNamePlist]) {
            _operationQueue = [NSMutableArray array];
        }else{
            NSArray *array = (NSArray *)[NSArray arrayWithContentsOfFile:kTMLRUManagerNamePlist];
            _operationQueue= [NSMutableArray arrayWithArray:array];
        }
    }
    return self;
}

- (void)addFileNode:(NSString *)filename {
    NSArray *array = [_operationQueue copy];
    /* 遍历 */
    [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"fileName"] isEqualToString:filename]) {
            [_operationQueue removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    
    NSDate *date = [NSDate date];
    NSDictionary *newDic = @{@"fileName":filename,@"date":date};
    [_operationQueue addObject:newDic];
    
    /* 写入文件 */
    [[_operationQueue copy] writeToFile:kTMLRUManagerNamePlist atomically:YES];
}

- (void)refreshIndexOfFileNode:(NSString *)filename {
    [self addFileNode:filename];
}

- (NSArray *)removeLRUFileNodeWithCacheTime:(NSTimeInterval)time {
    NSMutableArray *result = [NSMutableArray array];
    
    if (_operationQueue.count > 0) {
        NSArray *tmpArray = [_operationQueue copy];
        [tmpArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDate *date = obj[@"date"];
            NSDate *newDate = [date dateByAddingTimeInterval:time];
            if ([[NSDate date] compare:newDate] == NSOrderedDescending) {
                [result addObject:obj[@"fileName"]];
                [_operationQueue removeObjectAtIndex:idx];
            }
        }];
        
        if (result.count == 0) {
            NSString *removeFileName = [_operationQueue firstObject][@"fileName"];
            [result addObject:removeFileName];
            [_operationQueue removeObjectAtIndex:0];
        }
        
        [[_operationQueue copy] writeToFile:kTMLRUManagerNamePlist atomically:YES];
    }
    return [result copy];
}

- (NSArray *)currentQueue {
    return [_operationQueue copy];
}

@end
