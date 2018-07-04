//
//  BugAssistiveMemoryHelper.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveMemoryHelper.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

static vm_size_t            jPageSize = 0;
static vm_statistics_data_t jVMStats;

#define KB    (1024)
#define MB    (KB * 1024)
#define GB    (MB * 1024)

@implementation BugAssistiveMemoryHelper

+ (NSString *)bytesOfUsedMemory
{
    struct mstats stat = mstats();
    NSString *text = [BugAssistiveMemoryHelper number2String:stat.bytes_used];
    return  text;
}

+ (NSString *)bytesOfAllMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return nil;
    }
    return [self number2String:taskInfo.resident_size];
}

+ (NSString* )number2String:(int64_t)n{
    if ( n < KB ){
        return [NSString stringWithFormat:@"%lldB", n];
    }
    else if ( n < MB ){
        return [NSString stringWithFormat:@"%.1fKB", (float)n / (float)KB];
    }
    else if ( n < GB ){
        return [NSString stringWithFormat:@"%.1fMB", (float)n / (float)MB];
    }
    else{
        return [NSString stringWithFormat:@"%.1fGB", (float)n / (float)GB];
    }
}

@end
