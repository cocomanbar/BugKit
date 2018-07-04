//
//  BugAssistiveKeyboardView.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/21.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveKeyboardView.h"
#import "BugAssistiveConstants.h"

@interface BugAssistiveKeyboardView ()

@property (nonatomic, strong)UIButton *hiddenButton;
@property (nonatomic, strong)UILabel *numberLabel;

@end

@implementation BugAssistiveKeyboardView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, BugAssistive_SCREENWIDTH, 40);
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        [self addSubview:self.numberLabel];
        [self addSubview:self.hiddenButton];
    }
    return self;
}

- (void)onPullDownKeyBoard{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBugAssistiveKeyboardViewDidHiddenKeyBoard:)]) {
        [self.delegate onBugAssistiveKeyboardViewDidHiddenKeyBoard:self];
    }
}

#pragma mark - public

- (void)showNumber:(NSInteger)number{
    if (number > 300) {
        [self.numberLabel setText:[NSString stringWithFormat:@"超出：%ld",number-300]];
        self.numberLabel.textColor = [UIColor redColor];
    }else{
        [self.numberLabel setText:[NSString stringWithFormat:@"字数：%ld",number]];
        self.numberLabel.textColor = [UIColor darkGrayColor];
    }
}

#pragma mark - lazyLoad

- (UILabel *)numberLabel{
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 80, 40)];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:14];
    }
    return _numberLabel;
}

- (UIButton *)hiddenButton{
    if (!_hiddenButton) {
        _hiddenButton = [UIButton new];
        _hiddenButton.frame = CGRectMake(BugAssistive_SCREENWIDTH-40, 0, 40, 40);
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *close = [bundle pathForResource:@"source/down@2x" ofType:@"png"];
        UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [_hiddenButton setImage:image forState:UIControlStateNormal];
        [_hiddenButton setImage:image forState:UIControlStateHighlighted];
        [_hiddenButton addTarget:self action:@selector(onPullDownKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hiddenButton;
}

@end
