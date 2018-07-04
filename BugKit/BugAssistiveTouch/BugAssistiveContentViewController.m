//
//  BugAssistiveContentViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/19.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveContentViewController.h"
#import "BugAssistiveConstants.h"
#import "BugAssistiveTextView.h"

@interface BugAssistiveContentViewController ()

@property (nonatomic, strong)BugAssistiveTextView *textView;

@end

@implementation BugAssistiveContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    /* rightItemConfig */
    [self rightItemConfig];
    
    /* textView */
    self.textView = [[BugAssistiveTextView alloc] initWithFrame:self.view.bounds];
    [self.textView setEditable:NO];
    self.textView.text = self.content;
    [self.view addSubview:self.textView];
    [self.textView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - rightItemConfig

- (void)rightItemConfig{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *close = [bundle pathForResource:@"source/copy@2x" ofType:@"png"];
    UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onRightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)onRightItemClick{
    [self.textView setContentOffset:CGPointMake(0, 0)];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *text = @"复制成功！";
    pasteboard.string = [self.content copy];
    NSString *copyText = [NSString stringWithFormat:@"%@\n\n%@", text, self.content];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:copyText];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[UIFont boldSystemFontOfSize:20] forKey:NSFontAttributeName];
    [dict setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    [attributedString addAttributes:dict range:NSMakeRange(0, text.length)];
    
    self.textView.attributedText = attributedString;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.textView.text = weakSelf.content;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
