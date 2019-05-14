//
//  BGTaskManager.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "BGTaskManager.h"

@interface BGTaskManager ()
{
    dispatch_queue_t _queue;
}
//用来打印测试
@property (nonatomic,strong) NSTimer *timerLog;
@property (nonatomic,assign) NSInteger count;

@property (nonatomic, strong)NSMutableArray<NSNumber *>* bgTaskIdList; //后台任务数组
@property (assign) UIBackgroundTaskIdentifier masterTaskId; //当前后台任务id

@end

@implementation BGTaskManager

+ (instancetype)sharedManager {
    static BGTaskManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _bgTaskIdList = [NSMutableArray new];
    _masterTaskId = UIBackgroundTaskInvalid;
}

#pragma mark 开启新的后台任务
- (UIBackgroundTaskIdentifier)beginNewBackgroundTask
{
    UIApplication *application = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;
    if ([application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]) {
        bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"bgTask 过期 %lu",(unsigned long)bgTaskId);
            [application endBackgroundTask:bgTaskId];
            [self.bgTaskIdList removeObject:@(bgTaskId)];
        }];
    }
    //如果上次记录的后台任务已经失效了，就记录最新的任务为主任务
    [self endBackGroundTask];
    self.masterTaskId = bgTaskId;
    [self.bgTaskIdList addObject:@(bgTaskId)];
    
    return bgTaskId;
}
//去处多余残留的后台任务，只保留最新的创建的 主后台任务
-(void)endBackGroundTask
{
    UIApplication *application = [UIApplication sharedApplication];
    //结束所有旧后台任务
    if ([application respondsToSelector:@selector(endBackgroundTask:)]) {
        for (NSNumber *taskIdNum in self.bgTaskIdList) {
            UIBackgroundTaskIdentifier bgTaskId = taskIdNum.integerValue;
            NSLog(@"关闭后台任务 %lu",(unsigned long)bgTaskId);
            [application endBackgroundTask:bgTaskId];
        }
        [self.bgTaskIdList removeAllObjects];
    }
}

#pragma mark 打印
static NSString *const countTime = @"countTime";
//启动打印
- (void)startPrint {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"countTime:%ld",[defaults integerForKey:countTime]);
    _count = 0;
    
    [[NSRunLoop currentRunLoop] addTimer:self.timerLog forMode:NSDefaultRunLoopMode];
    
}
//停止打印
- (void)stopPrint {
    [self releaseTimer:_timerLog];
}
- (NSTimer *)timerLog {
    if (!_timerLog) {
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1 target:self selector:@selector(log) userInfo:nil repeats:YES];
        _timerLog = timer;
    }
    return _timerLog;
}
- (void)log {
    _count++;
    [[NSUserDefaults standardUserDefaults] setInteger:_count forKey:countTime];
}
- (void)releaseTimer:(NSTimer *)timer {
    if (timer.isValid) {
        [timer invalidate];
        timer = nil;
    }
}
@end
