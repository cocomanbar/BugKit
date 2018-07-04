//
//  BugAssistiveConstants.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/18.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#ifndef BugAssistiveConstants_h
#define BugAssistiveConstants_h

#define BugAssistive_SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define BugAssistive_SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define BugAssistive_KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define BugAssistive_TitleFont [UIFont fontWithName:@"Arial-BoldMT" size:16]

#define BugAssistive_detailFont [UIFont fontWithName:@"Courier" size:14]






#endif /* BugAssistiveConstants_h */
