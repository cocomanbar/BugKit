//
//  BugAssistiveConfig.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/24.
//  Copyright © 2018年 cocomanber. All rights reserved.
//  项目配置类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BugAssistiveConfig : NSObject

+(instancetype)shareManager;

/* * * * * 功能 * * * * */

/* 是否安装crash插件, 强制默认YES */
@property (nonatomic, assign, readonly)BOOL installCrashPlug;

/* 是否重定向log输出文件, 重定向后将不会在Xcode面板输出, 默认YES */
@property (nonatomic, assign)BOOL showLogs;

/* 是否注入NSURLProtocol子类, 捕获数据, 强制默认YES */
@property (nonatomic, assign, readonly)BOOL markProtocal;

/* 是否展示PFS(流畅性监测), 强制默认YES */
@property (nonatomic, assign, readonly)BOOL showPFS;

/* 显示总内存占用, 默认YES, NO为已用内存 */
@property (nonatomic, assign)BOOL showMemory;

/* * * * * 外观 * * * * */

/* 导航栏,默认YES */
@property (nonatomic, assign)BOOL hasNavi;

/* 分栏,默认YES */
@property (nonatomic, assign)BOOL hasTabB;

/* 主动停留边缘, 默认YES */
@property (nonatomic, assign)BOOL stopEdge;

/* 运动时的透明度, 默认0.8 */
@property (nonatomic, assign)CGFloat runAlpha;

/* 停止时的透明度, 默认0.6 */
@property (nonatomic, assign)CGFloat stopAlpha;

/* 背景色, 默认是blackColor */
@property (nonatomic, strong)UIColor *backgroundColor;

/* 是否自动改变透明度, 强制默认YES */
@property (nonatomic, assign, readonly)BOOL autoChangeAlpha;

#pragma mark - 以下属性千万不要赋值,谢谢。

@property (nonatomic, assign)int isLogViewController;

@end
