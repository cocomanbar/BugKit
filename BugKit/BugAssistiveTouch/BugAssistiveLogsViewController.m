//
//  BugAssistiveLogsViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/17.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveLogsViewController.h"
#import "BugAssistiveConstants.h"
#import "BugAssistiveManager.h"
#import "BugAssistiveConfig.h"

@interface BugAssistiveLogsViewController ()
<UITextViewDelegate>

@property (nonatomic, strong)UITextView *logTextView;
//@property (nonatomic, strong)NSTimer *logTimer;

@end

@implementation BugAssistiveLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if ([BugAssistiveConfig shareManager].showLogs) {
        /* rightItemConfig */
        [self rightItemConfig];
    }
    
    /* UITextView */
    [self.view addSubview:self.logTextView];
    self.logTextView.frame = self.view.bounds;
    self.logTextView.editable = NO;
    
    /* Notification */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onBugAssistiveDidRefrashLogsNotification:) name:BugAssistiveDidRefrashLogsNotification
                                               object:nil];
}

#pragma mark - notification

- (void)onBugAssistiveDidRefrashLogsNotification:(NSNotification *)notif{
    if ([BugAssistiveConfig shareManager].showLogs) {
        [self onReadingLogs];
    }else{
        NSString *text = @"你没有开启log打印插件";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:[UIFont boldSystemFontOfSize:20] forKey:NSFontAttributeName];
        [dict setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        [attributedString addAttributes:dict range:NSMakeRange(0, text.length)];
        self.logTextView.attributedText = attributedString;
        __weak __typeof(&*self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.logTextView.text = @"";
        });
    }
}

#pragma mark - Timer

- (void)onReadingLogs{
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"dr.log"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    self.logTextView.attributedText = [[NSAttributedString alloc] initWithString:result attributes:attributes];
    CGFloat offset = self.logTextView.contentSize.height - self.logTextView.frame.size.height;
    if (offset > -10)
    {
        [self.logTextView setContentOffset:CGPointMake(0, offset) animated:YES];
    }
}

/* 重定向输出 */
- (void)onSendingLogsToFile
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"dr.log"];
    NSString *logPath = [document stringByAppendingPathComponent:fileName];
    
    NSFileManager *defaulManager = [NSFileManager defaultManager];
    [defaulManager removeItemAtPath:logPath error:nil];
    
    // 重定向输入输出流
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout); //NSLog
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr); //printf
}

#pragma mark - rightItemConfig

- (void)rightItemConfig{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *close = [bundle pathForResource:@"source/clean@2x" ofType:@"png"];
    UIImage *image = [[UIImage imageWithContentsOfFile:close] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onRightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)onRightItemClick{
    self.logTextView.text = @"";
    [self onSendingLogsToFile];
}

#pragma mark - lazyLoad

- (UITextView *)logTextView{
    if (!_logTextView) {
        _logTextView = [[UITextView alloc]initWithFrame:CGRectZero];
        _logTextView.delegate = self;
        _logTextView.backgroundColor = [UIColor clearColor];
    }
    return _logTextView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
