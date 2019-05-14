//
//  KeepBGRunManager.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "KeepBGRunManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

#import "AudioPlayerManager.h"

//循环时间
static NSInteger circulDuration = 60;
@interface KeepBGRunManager ()
{
    dispatch_queue_t _queue;
}
@property (nonatomic,assign) UIBackgroundTaskIdentifier taskId;
//后台播放
@property (nonatomic,strong) AVAudioPlayer *playerBack;
@property (nonatomic,strong) NSTimer *timerAD;
//用来打印测试
@property (nonatomic,strong) NSTimer *timerLog;
@property (nonatomic,assign) NSInteger count;

@end

@implementation KeepBGRunManager

+ (instancetype)sharedManager {
    static KeepBGRunManager *manager = nil;
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
        [[AudioPlayerManager sharedManager] setBackGroundPlay];
        _queue = dispatch_queue_create("com.audio.inBackground", NULL);
    }
    return self;
}

/**
 启动后台运行
 */
-(void)startBGRun {
    [[AudioPlayerManager sharedManager] play];
    [self applyforBackgroundTask];
    
    NSLog(@"currentThread:%@",[NSThread currentThread]);
    //确保两个定时器同时进行
    dispatch_async(_queue, ^{
        self.timerLog = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1 target:self selector:@selector(log) userInfo:nil repeats:YES];
        self.timerAD = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:circulDuration target:self selector:@selector(startAudioPlay) userInfo:nil repeats:YES];
        //for test runloop
        NSLog(@"currentThread:%@",[NSThread currentThread]);
        NSLog(@"currentRunLoop:%@",[NSRunLoop currentRunLoop]);
        [[NSRunLoop currentRunLoop] addTimer:self.timerAD forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:self.timerLog forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
        NSLog(@"currentRunLoop:%@",[NSRunLoop currentRunLoop]);

    });
}
/**
 申请后台
 */
- (void)applyforBackgroundTask {
    __weak typeof(self) weakSelf = self;
    _taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.taskId];
            weakSelf.taskId = UIBackgroundTaskInvalid;
        });
    }];
}

#pragma mark actions
/**
 打印
 */
- (void)log {
    _count = _count + 1;
    NSLog(@"_count = %ld",_count);
}
/**
 检测后台运行时间
 */
- (void)startAudioPlay {
    _count = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].backgroundTimeRemaining < 6) {
            NSLog(@"后台快被杀死了");
            [[AudioPlayerManager sharedManager] play];
            [self applyforBackgroundTask];
        }else{
            NSLog(@"后台继续活跃呢");
        }
        ///再次执行播放器停止，后台一直不会播放音乐文件
        [[AudioPlayerManager sharedManager] stop];
    });
}

/**
 停止后台运行
 */
- (void)stopBGRun {
    if (_timerAD) {
        [self releaseTimer:_timerLog];
        [self releaseTimer:_timerAD];
        [[AudioPlayerManager sharedManager] stop];
    }
    if (_taskId) {
        [[UIApplication sharedApplication] endBackgroundTask:_taskId];
        _taskId = UIBackgroundTaskInvalid;
    }
}

- (void)releaseTimer:(NSTimer *)timer {
    if (timer.isValid) {
        [timer invalidate];
        timer = nil;
    }
}

@end
