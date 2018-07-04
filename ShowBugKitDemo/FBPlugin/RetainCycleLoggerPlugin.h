//
//  RetainCycleLoggerPlugin.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/31.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBMemoryProfiler/FBMemoryProfiler.h>

@interface RetainCycleLoggerPlugin : NSObject<FBMemoryProfilerPluggable>

@end
