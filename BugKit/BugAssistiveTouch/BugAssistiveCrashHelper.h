//
//  BugAssistiveCrashHelper.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/18.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BugAssistiveCrashSituationType){
    BugAssistiveCrashSituationTypeNone      = 0,
    BugAssistiveCrashSituationTypeSimple    = 1,
    BugAssistiveCrashSituationTypeMedium    = 2,
    BugAssistiveCrashSituationTypeDifficult = 3,
};

@interface BugAssistiveCrashHelper : NSObject

/* 单例 */
+ (instancetype)sharedInstance;

/* 安装插件 */
- (void)install;

/* crash log 对应的key 列表 */
- (NSArray* )crashPlist;

/* crash log 列表 */
- (NSArray* )crashLogs;

/* 取出对应key的crashlog*/
- (NSDictionary *)crashForKey:(NSString* )key;

/* 替换对应key的crashlog 和key列表对应值*/
- (void)replaceCrashLogToFileByKey:(NSString *)key withDict:(NSDictionary *)dict;

/* 删除某key对应的crashlog 和key列表对应值*/
- (void)deleteCrashLogFromDateKey:(NSString *)key;

@end
