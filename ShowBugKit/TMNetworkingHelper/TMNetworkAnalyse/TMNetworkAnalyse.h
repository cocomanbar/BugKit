//
//  TMNetworkAnalyse.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/29.
//  Copyright © 2018年 cocomanber. All rights reserved.
//  接口请求失败统计类

#import <Foundation/Foundation.h>

@interface TMNetworkAnalyse : NSObject

#pragma mark -

+ (instancetype)shareManager;

#pragma mark -

/**
 返回接口分析文件路径
 
 @return 路径
 */
@property (nonatomic, copy, readonly)NSString *networkAnalysePath;


/**
 获取这段时间内应用请求网络的api失败请求百分比
 
 @return 返回分数
 */
- (NSString *)failurePercent;


/**
 获取这段时间内应用请求网络的api失败集合
 
 @return dict
 */
- (NSArray *)getAPINetworkAnalyseFailurejson;


/**
 存请求结果分析
 
 @param baseUrl url
 @param ret @1/@0
 */
- (void)saveAPINetworkAnalyse:(NSString *)baseUrl andParameter:(NSDictionary *)parameter andBool:(BOOL)ret;

#pragma mark - 采取静默上传,接口切记要完好

- (void)updateDataToServer;

@end
