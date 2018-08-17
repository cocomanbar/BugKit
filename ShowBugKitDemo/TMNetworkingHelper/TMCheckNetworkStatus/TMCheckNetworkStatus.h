//
//  TMCheckNetworkStatus.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/26.
//  Copyright © 2018年 cocomanber. All rights reserved.
//  请初始化在Applelegate.m

#import <Foundation/Foundation.h>

@interface TMCheckNetworkStatus : NSObject

/* 开启网络检测 */
+ (void)tm_StartNetworking;

/* 数据网络 */
+ (BOOL)tm_4GNetworking;

/* 无网络 */
+ (BOOL)tm_NoNetworking;

/* Wi-Fi网络 */
+ (BOOL)tm_WiFiNetworking;

@end
