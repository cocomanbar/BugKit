//
//  TMNetworkingHelper+requsetManager.m
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TMNetworkingHelper+requsetManager.h"

@interface NSURLRequest (decide)

//判断是否是同一个请求（依据是请求url和参数是否相同）
- (BOOL)isTheSameRequest:(NSURLRequest *)request;

@end

@implementation NSURLRequest (decide)

- (BOOL)isTheSameRequest:(NSURLRequest *)request {
    if ([self.HTTPMethod isEqualToString:request.HTTPMethod]) {
        if ([self.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
            if ([self.HTTPMethod isEqualToString:@"GET"]||[self.HTTPBody isEqualToData:request.HTTPBody]) {
                return YES;
            }
        }
    }
    return NO;
}

@end

@implementation TMNetworkingHelper (requsetManager)

+ (BOOL)haveSameRequestInTasksPool:(TMURLSessionTask *)task {
    __block BOOL isSame = NO;
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(TMURLSessionTask *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.originalRequest isTheSameRequest:obj.originalRequest]) {
            isSame  = YES;
            *stop = YES;
        }
    }];
    return isSame;
}

+ (TMURLSessionTask *)cancleSameRequestInTasksPool:(TMURLSessionTask *)task {
    __block TMURLSessionTask *oldTask = nil;
    
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(TMURLSessionTask *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.originalRequest isTheSameRequest:obj.originalRequest]) {
            if (obj.state == NSURLSessionTaskStateRunning) {
                [obj cancel];
                oldTask = obj;
            }
            *stop = YES;
        }
    }];
    
    return oldTask;
}

@end
