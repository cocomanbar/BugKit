//
//  BugAssistiveCrashCell.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/19.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BugAssistiveCrashCell : UITableViewCell

+ (CGFloat)rowHeight;

- (void)loadDataWithDict:(NSDictionary *)log;

@end
