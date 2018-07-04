//
//  BugAssistiveHttpHelper.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveHttpHelper.h"

@implementation BugAssistiveHttpHelper

#pragma mark - manager

+ (instancetype)shareInstance
{
    static BugAssistiveHttpHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BugAssistiveHttpHelper alloc]init];
    });
    return instance;
}

+ (NSString *)currentTimeFormatter
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}


@end
