//
//  NSURLSessionTask+BugAssistiveData.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "NSURLSessionTask+BugAssistiveData.h"
#import <objc/runtime.h>

@implementation NSURLSessionTask (BugAssistiveData)

- (NSString*)taskDataIdentify {
    return objc_getAssociatedObject(self, @"taskDataIdentify");
}

- (void)setTaskDataIdentify:(NSString*)name {
    objc_setAssociatedObject(self, @"taskDataIdentify", name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableData*)responseDatas {
    return objc_getAssociatedObject(self, @"responseDatas");
}

- (void)setResponseDatas:(NSMutableData*)data {
    objc_setAssociatedObject(self, @"responseDatas", data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
