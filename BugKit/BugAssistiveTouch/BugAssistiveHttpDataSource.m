//
//  BugAssistiveHttpDataSource.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveHttpDataSource.h"
#import "NSURLRequest+BugAssistiveIdentify.h"
#import "NSURLResponse+BugAssistiveData.h"
#import "NSURLSessionTask+BugAssistiveData.h"
#import "BugAssistiveHttpHelper.h"

@implementation BugAssistiveHttpModel

@end

@implementation BugAssistiveHttpDataSource

+ (instancetype)shareInstance {
    static BugAssistiveHttpDataSource* tool;
    static dispatch_once_t  once;
    dispatch_once(&once, ^{
        tool = [[BugAssistiveHttpDataSource alloc] init];
    });
    return tool;
}

- (id)init {
    self = [super init];
    if (self) {
        _httpArray  = [NSMutableArray array];
        _arrRequest = [NSMutableArray array];
        _arrTasks   = [NSMutableArray array];
    }
    return self;
}

- (void)addHttpRequset:(BugAssistiveHttpModel *)model {
    @synchronized(self.httpArray) {
        if (model && ![self.httpArray containsObject:model]) {
            [self.httpArray insertObject:model atIndex:0];
        }
    }
}

- (void)addHttpTaskRequestId:(NSString *)requestId{
    @synchronized(self.arrRequest) {
        if (requestId && ![self.arrRequest containsObject:requestId]) {
            [self.arrRequest insertObject:requestId atIndex:0];
        }
    }
}

- (void)addHttpTaskIdentify:(NSString *)identify{
    @synchronized(self.arrTasks) {
        if (identify && ![self.arrTasks containsObject:identify]) {
            [self.arrTasks insertObject:identify atIndex:0];
        }
    }
}

- (void)clear {
    @synchronized(self.httpArray) {
        [self.httpArray removeAllObjects];
    }
    @synchronized(self.arrRequest) {
        [self.arrRequest removeAllObjects];
    }
    @synchronized(self.arrTasks) {
        [self.arrTasks removeAllObjects];
    }
}


#pragma mark - parse

+ (NSString *)prettyJSONStringFromData:(NSData *)data
{
    if (data == nil || data.length <= 0) {
        return nil;
    }
    NSString *prettyString = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        prettyString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL] encoding:NSUTF8StringEncoding];
        // NSJSONSerialization转义正斜杠。 我们想要漂亮的json，所以通过并避开斜杠。
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return prettyString;
}

@end
