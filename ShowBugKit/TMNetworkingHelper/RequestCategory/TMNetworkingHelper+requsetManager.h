//
//  TMNetworkingHelper+requsetManager.h
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//


#import "TMNetworkingHelper.h"

@interface TMNetworkingHelper (requsetManager)

/**
 *  判断网络请求池中是否有相同的请求
 *
 *  @param task 网络请求任务
 *
 *  @return BOOL
 */
+ (BOOL)haveSameRequestInTasksPool:(TMURLSessionTask *)task;

/**
 *  如果有旧请求则取消旧请求
 *
 *  @param task 新请求
 *
 *  @return 旧请求
 */
+ (TMURLSessionTask *)cancleSameRequestInTasksPool:(TMURLSessionTask *)task;

@end
