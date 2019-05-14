//
//  ViewController.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger count;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

//Audio UI
@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UIButton *pauseBtn;
@property (nonatomic,strong)UIButton *stopBtn;

@end

static NSString *const countTime = @"countTime";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"countTime:%ld",[[NSUserDefaults standardUserDefaults] integerForKey:countTime]);
    [self testTask];
}

- (void)testTask {
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
}

- (void)buildView {
    [self.view addSubview:self.playBtn];
}

#pragma mark setter and getter
- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn = aButton;
        aButton.frame = CGRectMake(50, 100, 100, 100);
        [aButton setTitle:@"播放音乐" forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if (!_pauseBtn) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pauseBtn = aButton;
        aButton.frame = CGRectMake(50, 250, 100, 100);
        [aButton setTitle:@"播放音乐" forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseBtn;
}
- (UIButton *)stopBtn {
    if (!_stopBtn) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopBtn = aButton;
        aButton.frame = CGRectMake(50, 400, 100, 100);
        [aButton setTitle:@"播放音乐" forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopBtn;
}



#pragma mark 音乐播放
-(AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        
        // 0. 设置后台音频会话
        //[self setBackGroundPlay];
        
         // 1. 获取资源URL
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"简单爱.mp3" ofType:nil];
         // 2. 根据资源URL, 创建 AVAudioPlayer 对象
        NSError *error = nil;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:&error];
        if (error) {
            NSLog(@"error:%@",error);
        }
        

        
        // 4. 设置代理, 监听播放事件
        player.delegate = self;
        
        _audioPlayer = player;
        
    }
    return _audioPlayer;
}
- (void)setBackGroundPlay {
    // 1. 设置会话模式
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }
    // 2. 激活会话
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }
}

//开始播放
- (void)play {
    // 3. 准备播放
    [self.audioPlayer prepareToPlay];
    
    // 2.1 设置允许倍速播放
    self.audioPlayer.enableRate = YES;
    //self.audioPlayer.rate = 2.0;
    
    //暂停/播放  切换
    if (self.audioPlayer.isPlaying) {
        [self pause];
    }else {
        [self.audioPlayer play];
    }
}
// 暂停
- (void)pause {
    [self.audioPlayer pause];
}
// 停止
- (void)stop {
    // 停止某个音乐, 并不会重置播放时间, 下次再播放, 会从当前位置开始播放
    [self.audioPlayer stop];
    // 重置当前播放时间
    self.audioPlayer.currentTime = 0;
    // 或者直接清空重新创建
    //self.audioPlayer = nil;
}
// 快进5秒
- (void)fastForward {
    self.audioPlayer.currentTime += 5;
}
// 快退5秒
- (void)rewind {
    self.audioPlayer.currentTime -= 5;
}
// 2倍速播放
- (void)doubleRate {
    // 1.0 为正常
    // 设置允许调整播放速率, 注意, 此方法必须设置在准备播放之前(经测试, 在播放前也可以)
    //    self.audioPlayer.enableRate = YES;
    self.audioPlayer.rate = 2.0;
}
// 音量调节
- (void)volumeChange:(NSInteger)value{
    // 0.0 --- 1.0
    self.audioPlayer.volume = value;
}

#pragma mark 播放器代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放完成");
}

@end
