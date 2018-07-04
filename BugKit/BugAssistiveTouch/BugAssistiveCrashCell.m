//
//  BugAssistiveCrashCell.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/19.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveCrashCell.h"
#import "BugAssistiveConstants.h"

@interface BugAssistiveCrashCell ()

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *detailLabel;

@property (nonatomic, strong)UIImageView *recordView;
@property (nonatomic, strong)UIButton *situationButton;

@property (nonatomic, strong)UIButton *button_select_1;
@property (nonatomic, strong)UIButton *button_select_2;
@property (nonatomic, strong)UIButton *button_select_3;

@end

@implementation BugAssistiveCrashCell

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
        [self.contentView addSubview:self.recordView];
        
        [self.contentView addSubview:self.button_select_1];
        [self.contentView addSubview:self.button_select_2];
        [self.contentView addSubview:self.button_select_3];
        
        self.titleLabel.frame = CGRectMake(12, 6, 0, 20);
        self.detailLabel.frame = CGRectMake(12, 29, 0, 20);
        self.recordView.frame = CGRectMake(3, 2, 10, 10);
        
        CGFloat width = BugAssistive_SCREENWIDTH;
        CGFloat height = 30.f;
        CGFloat margin = 5.f;
        
        self.button_select_1.frame = CGRectMake(width-(margin+height)*1, (55-height)/2, height, height);
        self.button_select_2.frame = CGRectMake(width-(margin+height)*2, (55-height)/2, height, height);
        self.button_select_3.frame = CGRectMake(width-(margin+height)*3, (55-height)/2, height, height);
        
        self.self.button_select_1.userInteractionEnabled = NO;
        self.self.button_select_2.userInteractionEnabled = NO;
        self.self.button_select_3.userInteractionEnabled = NO;
    }
    return self;
}

- (void)loadDataWithDict:(NSDictionary *)log{
    
    NSString *title = log[@"date"];
    NSString *detailTitle = [NSString stringWithFormat:@"type：%@",log[@"type"]];
    self.titleLabel.text = title ? title : @"No Record";
    self.detailLabel.text = detailTitle ? detailTitle : @"No Detail";
    [self.titleLabel sizeToFit];
    [self.detailLabel sizeToFit];
    if ([[log objectForKey:@"read"] integerValue]) {
        self.recordView.hidden = YES;
    }else{
        self.recordView.hidden = NO;
    }
    
    /* 等级 */
    NSInteger lve = [[log objectForKey:@"situation"] integerValue];
    UIImage *image_situation;
    if (lve == 0) {
    }else if (lve == 1){
        image_situation = [self getLocalSourceByName:@"LV1@2x"];
    }else if (lve == 2){
        image_situation = [self getLocalSourceByName:@"LV2@2x"];
    }else{
        image_situation = [self getLocalSourceByName:@"LV3@2x"];
    }
    if (image_situation) {
        [self.button_select_1 setImage:image_situation forState:UIControlStateNormal];
        self.button_select_1.hidden = NO;
    }else{
        self.button_select_1.hidden = YES;
    }
    
    /* 修复状态 */
    NSInteger solution = [[log objectForKey:@"solution"] integerValue];
    if (solution == 0) {
        self.button_select_2.hidden = YES;
    }else{
        UIImage *image_solution = [self getLocalSourceByName:@"fixed@2x"];
        [self.button_select_2 setImage:image_solution forState:UIControlStateNormal];
        self.button_select_2.hidden = NO;
    }
    
    /* 是否有描述 */
    BOOL desrip = [self isBlankString:[log objectForKey:@"description"]];
    if (desrip) {
        self.button_select_3.hidden = YES;
    }else{
        self.button_select_3.hidden = NO;
        UIImage *image_desrip = [self getLocalSourceByName:@"content@2x"];
        [self.button_select_3 setImage:image_desrip forState:UIControlStateNormal];
    }
    
    [self.button_select_1 sizeToFit];
    [self.button_select_2 sizeToFit];
    [self.button_select_3 sizeToFit];
}

- (UIImage *)getLocalSourceByName:(NSString *)name{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *close = [bundle pathForResource:[NSString stringWithFormat:@"source/%@",name] ofType:@"png"];
    UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return image;
}

- (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

#pragma mark - lazyLoad

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

- (UIImageView *)recordView{
    if (!_recordView) {
        _recordView = [UIImageView new];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *close = [bundle pathForResource:@"source/unread@2x" ofType:@"png"];
        UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _recordView.image = image;
        _recordView.hidden = YES;
    }
    return _recordView;
}

- (UIButton *)button_select_1{
    if (!_button_select_1) {
        _button_select_1 = [UIButton new];
        _button_select_1.hidden = YES;
    }
    return _button_select_1;
}

- (UIButton *)button_select_2{
    if (!_button_select_2) {
        _button_select_2 = [UIButton new];
        _button_select_2.hidden = YES;
    }
    return _button_select_2;
}

- (UIButton *)button_select_3{
    if (!_button_select_3) {
        _button_select_3 = [UIButton new];
        _button_select_3.hidden = YES;
    }
    return _button_select_3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
