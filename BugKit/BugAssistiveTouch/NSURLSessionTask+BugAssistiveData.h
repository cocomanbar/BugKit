//
//  NSURLSessionTask+BugAssistiveData.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (BugAssistiveData)

- (NSString*)taskDataIdentify;
- (void)setTaskDataIdentify:(NSString *)name;

- (NSMutableData*)responseDatas;
- (void)setResponseDatas:(NSMutableData *)data;

@end
