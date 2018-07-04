//
//  BugAssistiveTextInputViewController.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/20.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^refreshSections)(void);

@interface BugAssistiveTextInputViewController : UIViewController

@property (nonatomic, strong)NSMutableDictionary *dict;

@property (nonatomic, copy)refreshSections refreshBlock;

@end
