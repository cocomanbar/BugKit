//
//  TMNetworkAnalyse.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/29.
//  Copyright © 2018年 cocomanber. All rights reserved.
//  接口请求失败统计类

#import "TMNetworkAnalyse.h"

static NSMutableArray   *_analyseArray;
static NSDateFormatter  *_formatter;
static NSString         *_verson;

#define kTMNetworkAnalyseFile [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"TMNetworkAnalyseFile"]
#define kTMNetworkAnalyseFilePlist [NSString stringWithFormat:@"%@%@",kTMNetworkAnalyseFile,@"/TMNetworkAnalyse.plist"]

@interface TMNetworkAnalyse ()

@end

@implementation TMNetworkAnalyse

#pragma mark -

+ (instancetype)shareManager {
    static TMNetworkAnalyse * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TMNetworkAnalyse alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        /* 创建文件夹 */
        if (![[NSFileManager defaultManager] fileExistsAtPath:kTMNetworkAnalyseFile]) {
            BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:kTMNetworkAnalyseFile
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil];
            if (!ret) {
                [[NSFileManager defaultManager] createDirectoryAtPath:kTMNetworkAnalyseFile
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
        }
        
        /* 取plist数据转数组, 数组装的是dict */
        if (![[NSFileManager defaultManager] fileExistsAtPath:kTMNetworkAnalyseFilePlist]) {
            _analyseArray = [NSMutableArray array];
        }else{
            NSArray *array = (NSArray *)[NSArray arrayWithContentsOfFile:kTMNetworkAnalyseFilePlist];
            _analyseArray= [NSMutableArray arrayWithArray:array];
        }
        
        /* 格式化 */
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        _verson = (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

#pragma mark -

- (NSString *)failurePercent{
    NSArray *array = [_analyseArray copy];
    if (array.count <= 0 || array == nil) {
        return @"0.00";
    }
    NSInteger success = 0;
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"bool"] intValue]) {
            success += 1;
        }
    }    
    return [NSString stringWithFormat:@"%ld/%ld",(array.count - success),array.count];
}

- (NSArray *)getAPINetworkAnalyseFailurejson{
    NSArray *array = [_analyseArray copy];
    if (array.count <= 0 || array == nil) {
        return nil;
    }
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        if (![[dict objectForKey:@"bool"] intValue]) {
            if (![temp containsObject:dict]) {
                [temp addObject:dict];
            }
        }
    }
    if (temp.count) {
        return temp.copy;
    }
    return nil;
}

- (void)saveAPINetworkAnalyse:(NSString *)baseUrl andParameter:(NSDictionary *)parameter andBool:(BOOL)ret{
    @synchronized(_analyseArray) {
        /* 其他信息收集统一加入该集合 */
        NSDictionary *dict = @{@"url":baseUrl?baseUrl:@"",
                               @"date":[_formatter stringFromDate:[NSDate date]],
                               @"bool":ret?@"1":@"0",
                               @"verson":_verson,
                               @"class":@"iOS",
                               @"parameter":parameter?parameter.copy:@""
                               };
        [_analyseArray addObject:dict];
        [[_analyseArray copy] writeToFile:kTMNetworkAnalyseFilePlist atomically:YES];
    }
}

#pragma mark -

- (void)updateDataToServer{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        /* 模拟上传操作 */
        dispatch_async(dispatch_get_main_queue(), ^{
            /* 上传成功清空plist和数组 */
            /* 上传失败则不管,定期检查该接口的完整性 */
        });
    });
}

@end
