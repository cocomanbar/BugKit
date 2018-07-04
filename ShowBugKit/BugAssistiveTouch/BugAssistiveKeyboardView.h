//
//  BugAssistiveKeyboardView.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/21.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BugAssistiveKeyboardView;
@protocol BugAssistiveKeyboardViewDelegate<NSObject>

- (void)onBugAssistiveKeyboardViewDidHiddenKeyBoard:(BugAssistiveKeyboardView *)keyBoardView;

@end

@interface BugAssistiveKeyboardView : UIView

@property (nonatomic, weak)id<BugAssistiveKeyboardViewDelegate> delegate;

/* 显示字数 */
- (void)showNumber:(NSInteger)number;

@end
