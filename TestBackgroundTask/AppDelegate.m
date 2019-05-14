//
//  AppDelegate.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger count;
@property (nonatomic,assign)UIBackgroundTaskIdentifier taskID;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self testTask];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [self beginBackgoundTask];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self endBackgoundTask:self.taskID];
}

#pragma mark -
static NSString *const countTime = @"countTime";
- (void)testTask {
    NSLog(@"countTime:%ld",[[NSUserDefaults standardUserDefaults] integerForKey:countTime]);
    self.count = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:self.count forKey:countTime];
    [self timer];
}

#pragma mark timer
- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        _timer = timer;
    }
    return _timer;
}

- (void)releaseTimer {
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerAction {
    self.count++;
    [[NSUserDefaults standardUserDefaults] setInteger:self.count forKey:countTime];
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 6.0) {
        [self beginBackgoundTask];
    }
}
#pragma mark apply BackgoundTask
- (void)beginBackgoundTask {
    if (self.taskID) {//先结束前面旧的后台任务
        [self endBackgoundTask:self.taskID];
    }
    //开启新的后台任务
    self.taskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        [self endBackgoundTask:self.taskID];
    }];
}
- (void)endBackgoundTask:(UIBackgroundTaskIdentifier)taskID {
    [[UIApplication sharedApplication] endBackgroundTask:taskID];
}

@end
