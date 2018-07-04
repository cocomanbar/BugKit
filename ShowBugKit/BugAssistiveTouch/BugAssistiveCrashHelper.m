//
//  BugAssistiveCrashHelper.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/18.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveCrashHelper.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

@interface BugAssistiveCrashHelper ()
{
    NSString*       _crashLogPath;
    NSMutableArray* _plist;
}
@property (nonatomic,assign) BOOL isInstalled;

@end

@implementation BugAssistiveCrashHelper

#pragma mark - manager

+ (instancetype)sharedInstance
{
    static BugAssistiveCrashHelper* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BugAssistiveCrashHelper alloc]init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        /* /Library/Caches/BugAssistiveCrashLog */
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* sandBoxPath  = [paths objectAtIndex:0];
        _crashLogPath = [sandBoxPath stringByAppendingPathComponent:@"BugAssistiveCrashLog"];
        if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:_crashLogPath] )
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_crashLogPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        NSLog(@"--_crashLogPath-->>%@",_crashLogPath);
        //creat plist and return list  datas
        if (YES == [[NSFileManager defaultManager] fileExistsAtPath:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"]])
        {
            _plist = [[NSMutableArray arrayWithContentsOfFile:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"]] mutableCopy];
        }
        else
            _plist = [NSMutableArray new];
    }
    return self;
}

/* crash log 对应的key 列表 */
- (NSArray* )crashPlist
{
    return [_plist copy];
}

/* crash log 列表 */
- (NSArray* )crashLogs
{
    NSMutableArray* ret = [NSMutableArray new];
    for (NSString* key in _plist) {
        NSString* filePath = [_crashLogPath stringByAppendingPathComponent:key];
        NSString* path = [filePath stringByAppendingString:@".plist"];
        NSDictionary* log = [NSDictionary dictionaryWithContentsOfFile:path];
        [ret addObject:log];
    }
    return [ret copy];
}

/* 保存crash log */

- (void)saveException:(NSException*)exception
{
    NSMutableDictionary * detail = [NSMutableDictionary dictionary];
    if ( exception.name )
    {
        [detail setObject:exception.name forKey:@"name"];
    }
    if ( exception.reason )
    {
        [detail setObject:exception.reason forKey:@"reason"];
    }
    if ( exception.userInfo )
    {
        [detail setObject:exception.userInfo forKey:@"userInfo"];
    }
    if ( exception.callStackSymbols )
    {
        [detail setObject:exception.callStackSymbols forKey:@"callStack"];
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:@"exception" forKey:@"type"];
    [dict setObject:detail forKey:@"info"];
    [self saveToFile:dict];
}


/* 保存crash 到文件,更新列表 */
- (void)saveToFile:(NSMutableDictionary*)dict
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    
    /* 日期 */
    [dict setObject:dateString forKey:@"date"];
    /* 难易度 */
    [dict setObject:@0 forKey:@"situation"];
    /* 是否已读 */
    [dict setObject:@0 forKey:@"read"];
    /* 是否解决 */
    [dict setObject:@0 forKey:@"solution"];
    /* 描述字段 */
    [dict setObject:@"" forKey:@"description"];
    
    /* 根据日期格式把文件写入本地 */
    NSString* savePath = [[_crashLogPath stringByAppendingPathComponent:dateString] stringByAppendingString:@".plist"];
    [dict writeToFile:savePath atomically:YES];
    
    /* 更新总列表 */
    [_plist insertObject:dateString atIndex:0];
    [_plist writeToFile:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"] atomically:YES];
    
    //maxCount
//    if (_plist.count > maxCrashLogNum)
//    {
//        [[NSFileManager defaultManager] removeItemAtPath:[_crashLogPath stringByAppendingPathComponent:_plist[0]] error:nil];
//        [_plist writeToFile:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"] atomically:YES];
//    }
}

#pragma mark - buplic

/*  取出对应key的crash log */
- (NSDictionary* )crashForKey:(NSString *)key
{
    NSString* filePath = [[_crashLogPath stringByAppendingPathComponent:key] stringByAppendingString:@".plist"];
    if (filePath == nil) {
        return nil;
    }
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dict;
}

/* 替换对应key的crash log */
- (void)replaceCrashLogToFileByKey:(NSString *)key withDict:(NSDictionary *)dict
{
    if (!key) {
        return;
    }
    NSString* savePath = [[_crashLogPath stringByAppendingPathComponent:key] stringByAppendingString:@".plist"];
    [dict.copy writeToFile:savePath atomically:YES];
}

/* 删除某key对应的crash */
- (void)deleteCrashLogFromDateKey:(NSString *)key
{
    //先从_plist移除记录
    if ([_plist containsObject:key]) {
        [_plist removeObject:key];
        [_plist writeToFile:[_crashLogPath stringByAppendingPathComponent:@"crashLog.plist"] atomically:YES];
    }
    //移除文件
    NSString *filePath = [[_crashLogPath stringByAppendingPathComponent:key] stringByAppendingString:@".plist"];
    if (filePath) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

#pragma mark - register

void BugAssistive_HandleException(NSException *exception)
{
    [[BugAssistiveCrashHelper sharedInstance] saveException:exception];
    [exception raise];
}

void BugAssistive_SignalHandler(int sig)
{
    //    [[BugAssistiveCrashHelper sharedInstance] saveSignal:sig];
    //    signal(sig, SIG_DFL);
    //    raise(sig);
}

- (void)saveSignal:(int) signal
{
    NSMutableDictionary * detail = [NSMutableDictionary dictionary];
    [detail setObject:@(signal) forKey:@"signal type"];
    [self saveToFile:detail];
}

- (void)install
{
    if (_isInstalled) {
        return;
    }
    _isInstalled = YES;
    //注册回调函数
    NSSetUncaughtExceptionHandler(&BugAssistive_HandleException);
    signal(SIGABRT, BugAssistive_SignalHandler);
    signal(SIGILL, BugAssistive_SignalHandler);
    signal(SIGSEGV, BugAssistive_SignalHandler);
    signal(SIGFPE, BugAssistive_SignalHandler);
    signal(SIGBUS, BugAssistive_SignalHandler);
    signal(SIGPIPE, BugAssistive_SignalHandler);
}

- (void)dealloc
{
    signal( SIGABRT,    SIG_DFL );
    signal( SIGBUS,        SIG_DFL );
    signal( SIGFPE,        SIG_DFL );
    signal( SIGILL,        SIG_DFL );
    signal( SIGPIPE,    SIG_DFL );
    signal( SIGSEGV,    SIG_DFL );
}

@end
