//
//  BugAssistiveTextView.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/20.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveTextView.h"

@interface BugAssistiveTextView ()

@property (nonatomic, strong)UILabel *placeHolderLabel;

@end

@implementation BugAssistiveTextView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        
        /* 行间距 */
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 5; //字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:15],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        self.typingAttributes = attributes;
        
        /* 光标颜色 */
        self.tintColor = [UIColor orangeColor];
        
        /* 弹性 */
        self.scrollEnabled = YES;
        self.bounces = YES;
        self.bouncesZoom = YES;
    }
    return self;
}

-(void)setPlaceholder:(NSString *)placeholder{
    
    if (_placeholder != placeholder) {
        _placeholder = placeholder;
        [self.placeHolderLabel removeFromSuperview];
        self.placeHolderLabel = nil;
        [self setNeedsDisplay];
    }
}

- (void)textChanged:(NSNotification *)notification{
    if ([[self placeholder] length] == 0) {
        return;
    }
    if ([[self text] length] == 0) {
        [[self viewWithTag:999] setAlpha:1.0];
    }
    else{
        [[self viewWithTag:999] setAlpha:0];
    }
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if ([[self placeholder] length] > 0) {
        if (_placeHolderLabel == nil) {
            _placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, self.bounds.size.width - 16, 0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    if ([[self text] length] == 0 && [[self placeholder] length] >0) {
        [[self viewWithTag:999] setAlpha:1.0];
    }
}

/* 重写返回光标frame的方法避免光标扩大问题 */
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect originalRect = [super caretRectForPosition:position];
    
    originalRect.size.height = self.font.lineHeight;
    originalRect.size.width = 2;
    
    return originalRect;
}

@end
