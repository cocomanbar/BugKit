//
//  RetainCycleLoggerPlugin.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/31.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "RetainCycleLoggerPlugin.h"

@implementation RetainCycleLoggerPlugin

- (void)memoryProfilerDidFindRetainCycles:(NSSet *)retainCycles
{
    if (retainCycles.count > 0)
    {
        NSLog(@"\nretainCycles = \n%@", retainCycles);
    }
}

@end
