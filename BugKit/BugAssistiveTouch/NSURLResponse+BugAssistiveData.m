//
//  NSURLResponse+BugAssistiveData.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "NSURLResponse+BugAssistiveData.h"
#import <objc/runtime.h>

@implementation NSURLResponse (BugAssistiveData)

- (NSData *)responseData {
    return objc_getAssociatedObject(self, @"responseData");
}

- (void)setResponseData:(NSData *)responseData {
    objc_setAssociatedObject(self, @"responseData", responseData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
