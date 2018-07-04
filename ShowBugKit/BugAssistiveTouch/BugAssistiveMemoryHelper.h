//
//  BugAssistiveMemoryHelper.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BugAssistiveMemoryHelper : NSObject

/* used */
+ (NSString *)bytesOfUsedMemory;

/* all */
+ (NSString *)bytesOfAllMemory;

@end
