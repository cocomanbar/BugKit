//
//  TMNetworkLogger.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/28.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMNetworkLogger : NSObject


/**
 show Request

 @param objc <#objc description#>
 */
+ (void)tmNetworkLoggerShowRequest:(id)objc;

/**
 show Response

 @param objc <#objc description#>
 */
+ (void)tmNetworkLoggerShowResponse:(id)objc;

/**
 show Error
 
 @param objc <#objc description#>
 */
+ (void)tmNetworkLoggerShowError:(id)objc;

@end
