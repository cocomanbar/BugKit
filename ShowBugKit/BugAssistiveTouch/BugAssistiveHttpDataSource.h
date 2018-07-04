//
//  BugAssistiveHttpDataSource.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BugAssistiveHttpModel : NSObject

@property (nonatomic,copy)NSString  *httpMark;  /* 仅仅是记录唯一性, 用来过滤重复插入数据源 */
@property (nonatomic,copy)NSURL     *url;
@property (nonatomic,copy)NSString  *method;
@property (nonatomic,copy)NSString  *requestBody;
@property (nonatomic,copy)NSString  *statusCode;
@property (nonatomic,copy)NSData    *responseData;
@property (nonatomic,assign)BOOL    isImage;
@property (nonatomic,copy)NSString  *mineType;
@property (nonatomic,copy)NSString  *startTime;
@property (nonatomic,copy)NSString  *totalDuration;

@end

@interface BugAssistiveHttpDataSource : NSObject

@property (nonatomic,strong,readonly) NSMutableArray    *httpArray;
@property (nonatomic,strong,readonly) NSMutableArray    *arrRequest;
@property (nonatomic,strong,readonly) NSMutableArray    *arrTasks;

+ (instancetype)shareInstance;

/**
 *  记录http请求
 *
 *  @param model http
 */
- (void)addHttpRequset:(BugAssistiveHttpModel *)model;

/* 记录GET请求标志 */
- (void)addHttpTaskIdentify:(NSString *)identify;
/* 记录POST请求标志 */
- (void)addHttpTaskRequestId:(NSString *)requestId;

/**
 *  清空
 */
- (void)clear;

/**
 *  解析
 *
 *  @param data _
 *  @return _
 */
+ (NSString *)prettyJSONStringFromData:(NSData *)data;

@end
