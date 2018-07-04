//
//  AppDelegate.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/16.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "AppDelegate.h"
#import "BugAssistive.h"
#import "TMCheckNetworkStatus.h"

#if DEBUG
#import <FBMemoryProfiler/FBMemoryProfiler.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "CacheCleanerPlugin.h"
#import "RetainCycleLoggerPlugin.h"
#endif

@interface AppDelegate ()
{
#if DEBUG
    FBMemoryProfiler *memoryProfiler;
#endif
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /* 网络检测 */
    [TMCheckNetworkStatus netWorkState:^(NSInteger netState) {
        
    }];
    
    /* BugKit */
    BugAssistiveConfig *config  = [BugAssistiveConfig shareManager];
    config.showLogs = YES;
    config.hasNavi = NO;
    config.hasTabB = NO;
    [BugAssistiveTouch showBugAssistiveTouchonView:self.window withConfig:config];
    
    
#if DEBUG
    /* FB内存检测 */
    NSArray *filters = @[FBFilterBlockWithObjectIvarRelation([UIView class], @"_subviewCache"),
                         FBFilterBlockWithObjectIvarRelation([UIPanGestureRecognizer class], @"_internalActiveTouches"),
                         
                         
                         
                         ];
    
    FBObjectGraphConfiguration *configuration =
    [[FBObjectGraphConfiguration alloc] initWithFilterBlocks:filters
                                         shouldInspectTimers:NO];
    
    memoryProfiler = [[FBMemoryProfiler alloc] initWithPlugins:@[[CacheCleanerPlugin new],
                                                                 [RetainCycleLoggerPlugin new]]
                              retainCycleDetectorConfiguration:configuration];
    [memoryProfiler enable];
#endif
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
