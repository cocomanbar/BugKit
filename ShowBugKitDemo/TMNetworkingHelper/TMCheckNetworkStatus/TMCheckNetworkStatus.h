//
//  TMCheckNetworkStatus.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/26.
//  Copyright © 2018年 cocomanber. All rights reserved.
//  请初始化在Applelegate.m

#import <Foundation/Foundation.h>

typedef void(^netStateBlock)(NSInteger netState);

@interface TMCheckNetworkStatus : NSObject

+(void)netWorkState:(netStateBlock)block;

/**
 是否有网络
 @return YES/NO
 */
+ (BOOL)isConnectionAvailable;

@end
