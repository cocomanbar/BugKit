//
//  BugAssistiveHttpCell.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/23.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveHttpCell.h"
#import "BugAssistiveHttpDataSource.h"
#import "BugAssistiveConstants.h"

@interface BugAssistiveHttpCell ()

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *detailLabel;

@end

@implementation BugAssistiveHttpCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (CGFloat)rowHeight
{
    return 55.f;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        
        self.titleLabel.frame = CGRectMake(12, 6, BugAssistive_SCREENWIDTH-24, 20);
        self.detailLabel.frame = CGRectMake(12, 29, BugAssistive_SCREENWIDTH-24, 20);
    }
    return self;
}

- (void)setTitleText:(NSString *)titleText{
    _titleText = titleText;
    self.titleLabel.text = titleText ? titleText : @"No Record";
}

- (void)setDetailText:(NSString *)detailText{
    _detailText = detailText;
    self.detailLabel.text = detailText ? detailText : @"No Record";
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = BugAssistive_TitleFont;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.textColor = [UIColor blackColor];
        _detailLabel.font = BugAssistive_detailFont;
    }
    return _detailLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
