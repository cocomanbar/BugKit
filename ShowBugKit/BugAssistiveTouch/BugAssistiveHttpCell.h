//
//  BugAssistiveHttpCell.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BugAssistiveHttpModel;
@interface BugAssistiveHttpCell : UITableViewCell

+ (CGFloat)rowHeight;

@property (nonatomic, strong)NSString *titleText;
@property (nonatomic, strong)NSString *detailText;

@end
