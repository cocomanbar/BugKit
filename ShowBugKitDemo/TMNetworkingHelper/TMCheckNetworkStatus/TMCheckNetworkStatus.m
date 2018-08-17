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

/* 开启网络检测 */
+ (void)tm_StartNetworking{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
}

/* 数据网络 */
+ (BOOL)tm_4GNetworking{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    if (reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN) {
        return YES;
    }else{
        return NO;
    }
}

/* 无网络 */
+ (BOOL)tm_NoNetworking{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    if (reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown ||
        reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return YES;
    }else{
        return NO;
    }
}

/* Wi-Fi网络 */
+ (BOOL)tm_WiFiNetworking{
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    if (reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        return YES;
    }else{
        return NO;
    }
}

@end
