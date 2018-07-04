//
//  TMCheckNetworkStatus.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/26.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "TMCheckNetworkStatus.h"
#import "AFNetworkReachabilityManager.h"

@implementation TMCheckNetworkStatus

+(void)netWorkState:(netStateBlock)block;
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 提示：要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        block(status);
    }];
}

//有无网络
+ (BOOL)isConnectionAvailable
{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    if (reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown ||
        reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return NO;
    }else{
        return YES;
    }
}

@end
