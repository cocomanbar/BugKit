//
//  BugAssistiveConfig.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/24.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveConfig.h"

@implementation BugAssistiveConfig

#pragma mark -

+ (instancetype)shareManager {
    static BugAssistiveConfig * _instance;
    static dispatch_once_t  once;
    dispatch_once(&once, ^{
        _instance = [[BugAssistiveConfig alloc] init];
    });
    return _instance;
}

#pragma mark -

- (instancetype)init{
    self = [super init];
    if (self) {
        _installCrashPlug = YES;
        _showLogs = YES;
        _showPFS = YES;
        _hasNavi = YES;
        _hasTabB = YES;
        _stopEdge = YES;
        _runAlpha = 0.8;
        _stopAlpha = 0.6;
        _markProtocal = YES;
        _showMemory = YES;
        _backgroundColor = [UIColor blackColor];
        _autoChangeAlpha = YES;
    
    }
    return self;
}

@end
