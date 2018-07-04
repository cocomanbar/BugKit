//
//  BugAssistiveManager.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/18.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 暂停Timer */
extern NSString *const BugAssistiveStopTimerNotification;

/* 启动Timer */
extern NSString *const BugAssistiveStartTimerNotification;

/* 暂时隐藏BugAssistiveTouch */
extern NSString *const BugAssistiveDidHiddenNotification;
extern NSString *const BugAssistiveDidShowNotification;

/* 刷新log */
extern NSString *const BugAssistiveDidRefrashLogsNotification;
