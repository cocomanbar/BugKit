//
//  NSURLRequest+BugAssistiveIdentify.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "NSURLRequest+BugAssistiveIdentify.h"
#import <objc/runtime.h>

@implementation NSURLRequest (BugAssistiveIdentify)

- (NSString *)requestId {
    return objc_getAssociatedObject(self, @"requestId");
}

- (void)setRequestId:(NSString *)requestId {
    objc_setAssociatedObject(self, @"requestId", requestId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber*)startTime {
    return objc_getAssociatedObject(self, @"startTime");
}

- (void)setStartTime:(NSNumber*)startTime {
    objc_setAssociatedObject(self, @"startTime", startTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
