//
//  BugAssistiveTextInputViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/20.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveTextInputViewController.h"
#import "BugAssistiveTextView.h"
#import "BugAssistiveConstants.h"
#import "BugAssistiveManager.h"
#import "BugAssistiveKeyboardView.h"
#import "BugAssistiveCrashHelper.h"

@interface BugAssistiveTextInputViewController ()
<BugAssistiveKeyboardViewDelegate,
UITextViewDelegate>

@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)BugAssistiveTextView *textView;
@property (nonatomic, strong)BugAssistiveKeyboardView *keyBoardView;

@end

@implementation BugAssistiveTextInputViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:BugAssistiveDidShowNotification object:nil];
}

#pragma mark 显示一个新的键盘就会调用
- (void)keyboardWillShow:(NSNotification *)note
{
    CGFloat keyboardH = [note.userInfo [UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat height = keyboardH;
        self.textView.frame = CGRectMake(0, 0, BugAssistive_SCREENWIDTH, self.view.frame.size.height - height);
        [self.scrollView setContentSize:CGSizeMake(0, self.view.frame.size.height - height)];
    }];
}

#pragma mark 隐藏键盘就会调用
- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.25 animations:^{
        self.textView.frame = self.view.bounds;
        [self.scrollView setContentSize:CGSizeMake(0, self.view.frame.size.height)];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:BugAssistiveDidHiddenNotification object:nil];
    
    // 1.显示键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 2.隐藏键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    self.scrollView = scrollView;
    scrollView.scrollEnabled = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.frame = CGRectMake(0, 0, BugAssistive_SCREENWIDTH, self.view.frame.size.height-1);
    scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:scrollView];
    [scrollView setContentSize:CGSizeMake(0, self.view.frame.size.height)];
    
    BugAssistiveTextView *textView = [[BugAssistiveTextView alloc] init];
    textView.frame = CGRectZero;
    [scrollView addSubview:textView];
    self.textView = textView;
    textView.delegate = self;
    textView.inputAccessoryView = self.keyBoardView;
    textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [textView setScrollEnabled:NO];
    
    NSString *description = [self.dict objectForKey:@"description"];
    if ([self isBlankString:description]) {
        self.textView.placeholder = @"分点详细说明crash日记的过程，以便开发人员快速定位问题。";
        self.textView.placeholderColor = [UIColor lightGrayColor];
        [self.keyBoardView showNumber:0];
    }
    else
    {
        self.textView.text = description;
        [self.keyBoardView showNumber:description.length];
    }
    
    [textView becomeFirstResponder];
    [self rightItemConfig];
}

#pragma mark - rightItemConfig

- (void)rightItemConfig{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *close = [bundle pathForResource:@"source/save@2x" ofType:@"png"];
    UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onRightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)onRightItemClick{
    [self.view endEditing:YES];
    [self.textView setContentOffset:CGPointMake(0, 0)];
    
    NSString *content = self.textView.text ? self.textView.text : @"";
    [self.dict setValue:content forKey:@"description"];
    [[BugAssistiveCrashHelper sharedInstance] replaceCrashLogToFileByKey:self.dict[@"date"] withDict:self.dict];
    
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    
    if ([self isBlankString:content]) {
        return;
    }
    
    NSString *text = @"保存成功！crash日记详情可查看";
    NSString *copyText = [NSString stringWithFormat:@"%@\n\n%@", text, content];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:copyText];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[UIFont boldSystemFontOfSize:20] forKey:NSFontAttributeName];
    [dict setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    /* 和继承类设置一样 */
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    [attributedString addAttributes:dict range:NSMakeRange(0, text.length)];
    [attributedString addAttributes:attributes range:NSMakeRange(text.length, copyText.length - text.length)];
    
    self.textView.attributedText = attributedString;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.textView.text = content;
    });
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView{
    [self.keyBoardView showNumber:textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if (textView.text.length + text.length > 300){
        if (location != NSNotFound){
            [textView resignFirstResponder];
        }
        return NO;
    }
    return YES;
}

#pragma mark - BugAssistiveKeyboardViewDelegate

- (void)onBugAssistiveKeyboardViewDidHiddenKeyBoard:(BugAssistiveKeyboardView *)keyBoardView{
    [self.textView resignFirstResponder];
}

#pragma mark -

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

- (BugAssistiveKeyboardView *)keyBoardView{
    if (!_keyBoardView) {
        _keyBoardView = [[BugAssistiveKeyboardView alloc]initWithFrame:CGRectZero];
        _keyBoardView.delegate = self;
    }
    return _keyBoardView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
