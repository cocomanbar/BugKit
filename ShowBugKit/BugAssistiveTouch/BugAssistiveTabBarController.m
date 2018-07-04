//
//  BugAssistiveTabBarController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/17.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveTabBarController.h"
#import "BugAssistiveManager.h"
#import "BugAssistiveConfig.h"

static NSString *rotationAnimationKey = @"TabBarButtonTransformRotationAnimationKey";

@interface BugAssistiveTabBarController ()
<UITabBarControllerDelegate>
{
    UIImage *_refreshImage;
}

/* 旋转动画 */
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;

@end

@implementation BugAssistiveTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBar.tintColor = [UIColor redColor];
    self.delegate = self;
    
    //初始化子控制器
    [self initChildrenViewController];
}

- (void)initChildrenViewController
{
    NSArray *viewControlls = @[@"BugAssistiveHttpsViewController",
                               @"BugAssistiveCrashViewController",
                               @"BugAssistiveLogsViewController"];
    
    NSArray *titles = @[@"Http",
                        @"Crash",
                        @"Logs"];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *http_normal = [bundle pathForResource:@"icon/http_normal@2x" ofType:@"png"];
    NSString *http_hight = [bundle pathForResource:@"icon/http_hight@2x" ofType:@"png"];
    NSString *crash_normal = [bundle pathForResource:@"icon/bug_normal@2x" ofType:@"png"];
    NSString *crash_hight = [bundle pathForResource:@"icon/bug_hight@2x" ofType:@"png"];
    NSString *logs_normal = [bundle pathForResource:@"icon/log_normal@2x" ofType:@"png"];
    NSString *logs_hight = [bundle pathForResource:@"icon/log_hight@2x" ofType:@"png"];
    
    NSArray *normalImages = @[http_normal,
                              crash_normal,
                              logs_normal];
    
    NSArray *selectedImages = @[http_hight,
                                crash_hight,
                                logs_hight];
    
    [viewControlls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *viewController;
        viewController = [[NSClassFromString(obj) alloc] init];
        viewController.title = titles[idx];
        viewController.tabBarItem.image = [[UIImage imageWithContentsOfFile:normalImages[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        viewController.tabBarItem.selectedImage = [[UIImage imageWithContentsOfFile:selectedImages[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.navigationBar.translucent = YES;
        [self addChildViewController:nav];
    }];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *controller = (UIViewController *)nav.viewControllers.firstObject;
    if ([controller isKindOfClass:NSClassFromString(@"BugAssistiveLogsViewController")]) {
        [BugAssistiveConfig shareManager].isLogViewController += 1;
    }else{
        [BugAssistiveConfig shareManager].isLogViewController = 0;
    }
    if ([BugAssistiveConfig shareManager].isLogViewController >= 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BugAssistiveDidRefrashLogsNotification object:nil];
        
        UIImageView *tabBarSwappableImageView = [self getTabBarButtonImageViewWithCurrentVc:viewController];
        if (tabBarSwappableImageView) {
            if (![[tabBarSwappableImageView layer] animationForKey:rotationAnimationKey])  {
                //选中和未选中的image都需要更改为刷新中的图，不然会出现正在刷新时切换TabBar导致未选中的图片在旋转
                if (!_refreshImage) {
                    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
                    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                    NSString *logs_hight = [bundle pathForResource:@"icon/log_hight@2x" ofType:@"png"];
                    UIImage *image = [[UIImage imageWithContentsOfFile:logs_hight] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    _refreshImage = image;
                }
                viewController.tabBarItem.selectedImage = _refreshImage;
                viewController.tabBarItem.image = _refreshImage;
                __weak __typeof(&*self)weakSelf = self;
                [self addTabBarButtonRotationAnimationWithCurrentViewController:viewController];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf removeTabBarButtonRotationAnimationWithCurrentViewController:controller];
                });
            }
        }
    }
}

#pragma mark - 动画

/**
 旋转动画
 
 @return CABasicAnimation 动画
 */
- (CABasicAnimation *)rotationAnimation{
    if (!_rotationAnimation) {
        //指定动画属性
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //单次动画时间
        _rotationAnimation.duration = 0.7;
        //重复次数
        _rotationAnimation.repeatCount= 99;
        //开始角度
        _rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
        //结束角度
        _rotationAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        // 是否在动画结束后移除动画
        _rotationAnimation.removedOnCompletion = NO;
    }
    return _rotationAnimation;
}

/**
 获取当前TabBarItem中的ImageView
 
 @param currentViewController 当前ViewController
 @return TabBarItem中的ImageView
 */
- (UIImageView *)getTabBarButtonImageViewWithCurrentVc:(UIViewController *)currentViewController{
    
    UIControl *tabBarButton = [currentViewController.tabBarItem valueForKey:@"view"];
    if (tabBarButton) {
        UIImageView *tabBarSwappableImageView = [tabBarButton valueForKey:@"info"];
        if (tabBarSwappableImageView) {
            return tabBarSwappableImageView;
        }
    }
    return nil;
}

/**
 添加旋转动画
 
 @param currentViewController 当前ViewController
 */
- (void)addTabBarButtonRotationAnimationWithCurrentViewController:(UIViewController *)currentViewController{
    
    UIImageView *tabBarSwappableImageView = [self getTabBarButtonImageViewWithCurrentVc:currentViewController];
    
    if (tabBarSwappableImageView) {
        [[tabBarSwappableImageView layer] addAnimation:self.rotationAnimation forKey:rotationAnimationKey];
    }
}

/**
 移除旋转动画
 
 @param currentViewController 当前ViewController
 */
- (void)removeTabBarButtonRotationAnimationWithCurrentViewController:(UIViewController *)currentViewController{
    
    UIImageView *tabBarSwappableImageView = [self getTabBarButtonImageViewWithCurrentVc:currentViewController];
    if (tabBarSwappableImageView) {
        if ([[tabBarSwappableImageView layer] animationForKey:rotationAnimationKey]) {
            [[tabBarSwappableImageView layer] removeAnimationForKey:rotationAnimationKey];
        }
    }
    
    //移除后重新更换选中和未选中的图片
    if ([currentViewController isKindOfClass:NSClassFromString(@"BugAssistiveLogsViewController")]) {
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"BugAssistiveBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *logs_hight = [bundle pathForResource:@"icon/log_hight@2x" ofType:@"png"];
        NSString *logs_normal = [bundle pathForResource:@"icon/log_normal@2x" ofType:@"png"];
        UIImage *image_hight = [[UIImage imageWithContentsOfFile:logs_hight] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *image_normal = [[UIImage imageWithContentsOfFile:logs_normal] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        currentViewController.tabBarItem.selectedImage = image_hight;
        currentViewController.tabBarItem.image = image_normal;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
