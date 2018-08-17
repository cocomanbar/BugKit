//
//  TMNetworkLogger.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/28.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "TMNetworkLogger.h"
#import "TMNetworkConfig.h"

@implementation TMNetworkLogger

/**
 show Request parameter
 
 @param objc <#objc description#>
 */
+ (void)tmNetworkLoggerShowRequest:(id)objc
{
    if ([TMNetworkConfig shareInstance].enableDebug) {
        if (objc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Request data：\n\n%@",objc);
            });
        }
    }
}

/**
 show Response data
 
 @param objc <#objc description#>
 */
+ (void)tmNetworkLoggerShowResponse:(id)objc
{
    if ([TMNetworkConfig shareInstance].enableDebug) {
        if (objc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Response data：\n\n%@",objc);
            });
        }
    }
}

/**
 show Error
 
 @param objc <#objc description#>
 */
+ (void)tmNetworkLoggerShowError:(id)objc
{
    if ([TMNetworkConfig shareInstance].enableDebug) {
        if (objc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error data：\n\n%@",objc);
            });
        }
    }
}

@end
