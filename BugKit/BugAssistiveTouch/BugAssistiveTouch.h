//
//  BugAssistiveTouch.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/17.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BugAssistiveConfig;
@interface BugAssistiveTouch : UIView

/**
 Method

 @param view superView
 */
+ (instancetype)showBugAssistiveTouchonView:(UIView *)view withConfig:(BugAssistiveConfig *)config;

@end
