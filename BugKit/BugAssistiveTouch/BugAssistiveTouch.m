//
//  BugAssistiveTouch.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/17.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveTouch.h"
#import "BugAssistiveTabBarController.h"
#import "BugAssistiveManager.h"
#import "BugAssistiveConfig.h"
#import "BugAssistiveCrashHelper.h"
#import "BugAssistiveSessionProtocol.h"
#import "BugAssistiveMemoryHelper.h"

#define kTouchViewMargin 5
#define kTouchViewWIDTH 60

@interface BugAssistiveTouch ()
{
    NSUInteger _tickCount;
    BugAssistiveConfig *_config;
}

@property (nonatomic, assign)BOOL hasNavi;
@property (nonatomic, assign)BOOL hasTabB;

@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, assign) CGRect initialFrame;
@property (nonatomic, strong) UIButton *assistivaButton;
@property (nonatomic, strong) UILabel *assistivaLabel;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat transX;
@property (nonatomic, assign) CGFloat transY;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval lastTime;
@property (nonatomic, assign) NSUInteger fps;

@property (nonatomic, strong)BugAssistiveTabBarController *tabBarViewController;
@property (nonatomic, assign)BOOL showingTabBar;

@property (nonatomic, strong)BugAssistiveTouch *touchView;

@end

@implementation BugAssistiveTouch

#pragma mark - 实现AssistiveTouch效果

/**
 唯一初始化Method
 
 @param view superView
 */
+ (instancetype)showBugAssistiveTouchonView:(UIView *)view withConfig:(BugAssistiveConfig *)config
{
    /* 注册crash插件 */
    if (config.installCrashPlug) {
        [[BugAssistiveCrashHelper sharedInstance] install];
    }
    
    /* 输出重定向 */
    if (config.showLogs) {
        [BugAssistiveTouch onSendingLogsToFile];
    }
    
    /* 注入NSURLProtocol子类 */
    if (config.markProtocal) {
        [NSURLProtocol registerClass:[BugAssistiveSessionProtocol class]];
    }
    
    /* 设置UI */
    BugAssistiveTouch *touchView = [[BugAssistiveTouch alloc]init];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [touchView setUIWithView:view withConfig:config];
    });
    return touchView;
}

/* 隐藏或显示的通知 */

- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBugAssistiveDidHiddenNotification)
                                                     name:BugAssistiveDidHiddenNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onBugAssistiveDidShowNotification)
                                                     name:BugAssistiveDidShowNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:BugAssistiveDidHiddenNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:BugAssistiveDidShowNotification];
    
    [_displayLink invalidate];
}

- (void)onBugAssistiveDidHiddenNotification{
    _touchView.hidden = YES;
}

- (void)onBugAssistiveDidShowNotification{
    _touchView.hidden = NO;
}

/* 重定向输出 */
+ (void)onSendingLogsToFile
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

- (void)setUIWithView:(UIView *)parentView withConfig:(BugAssistiveConfig *)config
{
    self.frame = CGRectMake(kTouchViewMargin, [UIScreen mainScreen].bounds.size.height / 2 - kTouchViewWIDTH / 2, kTouchViewWIDTH, kTouchViewWIDTH);
    self.layer.cornerRadius = kTouchViewWIDTH / 2;
    self.layer.masksToBounds = YES;
    _parentView = parentView;
    _initialFrame = self.frame;
    _hasNavi = config.hasNavi;
    _hasTabB = config.hasTabB;
    _touchView = self;
    _config = config;
    
    _assistivaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _assistivaButton.frame = self.bounds;//CGRectMake(0, 0, kTouchViewWIDTH, kTouchViewWIDTH);
    //_assistivaButton.layer.cornerRadius = kTouchViewWIDTH/2;
    //_assistivaButton.layer.masksToBounds = YES;
    _assistivaButton.backgroundColor = config.backgroundColor;
    //[_assistivaButton setTitle:@"DEBUG" forState:UIControlStateNormal];
    //[_assistivaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //_assistivaButton.titleLabel.font = [UIFont fontWithName:@"Menlo" size:14];
    //_assistivaButton.contentEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
    //_assistivaButton.titleLabel.numberOfLines = 2;
    //_assistivaButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.alpha = _config.stopAlpha;
    _assistivaButton.alpha = _config.stopAlpha;
    [_assistivaButton addTarget:self action:@selector(assistivaButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_assistivaButton];
    
    self.assistivaLabel.frame = self.bounds;
    [self addSubview:self.assistivaLabel];
    
    [parentView addSubview:self];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:panGesture];
    
    //autoChangeAlpha
    if (config.autoChangeAlpha) {
        [self addTimer];
    }else {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
    
    //FPS
    if (config.showPFS) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(fps)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    self.alpha = _config.runAlpha;
    _assistivaButton.alpha = _config.runAlpha;
    _transX = [panGesture translationInView:self].x;
    _transY = [panGesture translationInView:self].y;
    panGesture.view.center = CGPointMake(panGesture.view.center.x + _transX, panGesture.view.center.y + _transY);
    [panGesture setTranslation:CGPointZero inView:self];
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (_config.autoChangeAlpha) {
            [self addTimer];
        }else {
            if (_timer) {
                [_timer invalidate];
                _timer = nil;
            }
        }
        CGFloat self_x = self.frame.origin.x;
        CGFloat self_y = self.frame.origin.y;
        CGFloat self_w = self.frame.size.width;
        CGFloat self_H = self.frame.size.height;
        //修正坐标
        [self resetFrameX:self_x y:self_y w:self_w h:self_H];
        
        //停留在边缘
        if (_config.stopEdge) {
            if (self_y < touch_minY(self) + 3) {
                [self resetFrameX:self_x y:touch_minY(self) w:self_w h:self_H];
            }else {
                if (self_x < _parentView.frame.size.width/2.0) {
                    [self resetFrameX:touch_minX() y:self_y w:self_w h:self_H];
                }else {
                    [self resetFrameX:touch_maxX(self) y:self_y w:self_w h:self_H];
                }
            }
            if (self_y > touch_maxY(self) - 3) {
                if (self_x < _parentView.frame.size.width/2.0) {
                    [self resetFrameX:self_x y:touch_maxY(self) w:self_w h:self_H];
                }else {
                    [self resetFrameX:self_x y:touch_maxY(self) w:self_w h:self_H];
                }
            }
        }
    }
}

/* private */

- (void)resetFrameX:(CGFloat)x y:(CGFloat)y w:(CGFloat)width h:(CGFloat)height {
    if (x <= touch_minX())     x = touch_minX();
    if (x >= touch_maxX(self)) x = touch_maxX(self);
    
    if (y <= touch_minY(self)) y = touch_minY(self);
    if (y >= touch_maxY(self)) y = touch_maxY(self);
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(x, y, width, height);
    }];
}

- (void)addTimer {
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeAlpha) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)assistivaButtonClick:(UIButton *)sender {
    if (_config.autoChangeAlpha) {
        [self addTimer];
    }else {
        [_timer invalidate];
        _timer = nil;
    }
    self.alpha = _config.runAlpha;
    _assistivaButton.alpha = _config.runAlpha;
    
    //show TabBar
    if (self.showingTabBar) {
        if (self.tabBarViewController) {
            [self.tabBarViewController dismissViewControllerAnimated:YES completion:nil];
            self.showingTabBar = NO;
            [_assistivaButton setImage:[UIImage new] forState:UIControlStateNormal];
            NSString *memory = _config.showMemory ? [BugAssistiveMemoryHelper bytesOfAllMemory] : [BugAssistiveMemoryHelper bytesOfUsedMemory];
            NSString *text = [NSString stringWithFormat:@"%@\n%@", @(self.fps),memory];
            self.assistivaLabel.text = text;
            //stop logs Timer
            [[NSNotificationCenter defaultCenter] postNotificationName:BugAssistiveStopTimerNotification object:nil];
        }
    }else{
        //hidden TabBar
        UIViewController *viewController = [self getCurrentVC];
        [viewController presentViewController:self.tabBarViewController animated:YES completion:nil];
        self.showingTabBar = YES;
        //change button status
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *close = [bundle pathForResource:@"source/close@2x" ofType:@"png"];
        [_assistivaButton setImage:[UIImage imageWithContentsOfFile:close] forState:UIControlStateNormal];
        self.assistivaLabel.text = @"";
        //start logs Timer
        [[NSNotificationCenter defaultCenter] postNotificationName:BugAssistiveStartTimerNotification object:nil];
    }
}

- (void)changeAlpha {
    [UIView animateWithDuration:0.7 animations:^{
        self.alpha = _config.stopAlpha;
        self.assistivaButton.alpha = _config.stopAlpha;
    }];
    /* invalidate */
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

CGFloat touch_minY(BugAssistiveTouch* obj) {
    CGFloat top = 0.0;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (obj.hasNavi && screenH == 812.0) {
        top = 91.0;
    }
    if (obj.hasNavi && screenH != 812.0) {
        top = 67.0;
    }
    if (!obj.hasNavi) {
        top = 3.0;
    }
    return top;
}

CGFloat touch_maxY(BugAssistiveTouch* obj) {
    CGFloat bottom = 0.0;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    if (obj.hasTabB && screenH == 812.0) {
        bottom = 86.0;
    }
    if (obj.hasTabB && screenH != 812.0) {
        bottom = 52.0;
    }
    if (!obj.hasTabB) {
        bottom = 3.0;
    }
    return (obj.parentView.bounds.size.height - obj.initialFrame.size.height - bottom);
}

CGFloat touch_minX(void) {
    return 3.0;
}

CGFloat touch_maxX(BugAssistiveTouch* obj) {
    return (obj.parentView.bounds.size.width - obj.initialFrame.size.width - touch_minX());
}


#pragma mark - 实现FPS

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:NSStringFromSelector(@selector(fps))]) {
        NSUInteger oldFps = [[change valueForKey:NSKeyValueChangeOldKey] unsignedIntegerValue];
        NSUInteger newFps = [[change valueForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (oldFps != newFps) {
            [self displayFPS];
        }
    }
}

- (void)tick:(CADisplayLink *)displayLink
{
    CFTimeInterval currentTime = displayLink.timestamp;
    if (_lastTime == 0) {
        // first time.
        _lastTime = currentTime;
        return;
    }
    _tickCount++;
    CFTimeInterval delta = currentTime - _lastTime;
    if (delta < 1) return;
    // get fps
    self.fps = MIN(lrint(_tickCount / delta), 60);
    _tickCount = 0;
    _lastTime = currentTime;
}

- (void)displayFPS
{
    CGFloat hue = self.fps > 24 ? (self.fps - 24) / 120.f : 0;
    UIColor *textColor = [UIColor colorWithHue:hue saturation:1 brightness:0.9 alpha:1];
    NSString *memory = _config.showMemory ? [BugAssistiveMemoryHelper bytesOfAllMemory] : [BugAssistiveMemoryHelper bytesOfUsedMemory];
    NSString *text = [NSString stringWithFormat:@"%@\n%@", @(self.fps),memory];
    if (!self.showingTabBar) {
        self.assistivaLabel.text = text;
        self.assistivaLabel.textColor = textColor;
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

- (BugAssistiveTabBarController *)tabBarViewController{
    if (_tabBarViewController == nil) {
        _tabBarViewController = [[BugAssistiveTabBarController alloc]init];
    }
    return _tabBarViewController;
}

- (UILabel *)assistivaLabel{
    if (!_assistivaLabel) {
        UILabel *label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        label.font = [UIFont fontWithName:@"Menlo" size:14];
        label.text = @"DEBUG";
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        _assistivaLabel = label;
    }
    return _assistivaLabel;
}

@end

