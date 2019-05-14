//
//  AudioPlayerManager.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "AudioPlayerManager.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayerManager ()<AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@end

@implementation AudioPlayerManager

+ (instancetype)sharedManager {
    static AudioPlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AudioPlayerManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self audioPlayer];
    }
    return self;
}

#pragma mark 音乐播放
-(AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        
        // 0. 设置后台音频会话
        //[self setBackGroundPlay];
        
        // 1. 获取资源URL
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"遥远的她.mp3" ofType:nil];
        NSLog(@"filePath:%@",filePath);
        // 2. 根据资源URL, 创建 AVAudioPlayer 对象
        NSError *error = nil;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:filePath] error:&error];
        if (error) {
            NSLog(@"error:%@",error);
        }

        // 4. 设置代理, 监听播放事件
        player.delegate = self;
        
        // 循环播放
        player.numberOfLoops = -1;
        
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
    // 启动AudioSession，如果一个前台app正在播放音频则可能会启动失败
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
    }
    
    [self.audioPlayer play];
    
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
    if ([_delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:successfully:)]) {
        [_delegate audioPlayerDidFinishPlaying:player successfully:flag];
    }
}

@end
