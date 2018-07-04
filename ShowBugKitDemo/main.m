//
//  main.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/16.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#if DEBUG
#import <FBAllocationTracker/FBAllocationTrackerManager.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#endif

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
#if DEBUG
        [FBAssociationManager hook];
        [[FBAllocationTrackerManager sharedManager] startTrackingAllocations];
        [[FBAllocationTrackerManager sharedManager] enableGenerations];
#endif
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
