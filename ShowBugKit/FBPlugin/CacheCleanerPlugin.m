//
//  CacheCleanerPlugin.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/31.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "CacheCleanerPlugin.h"

@implementation CacheCleanerPlugin

- (void)memoryProfilerDidMarkNewGeneration {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
