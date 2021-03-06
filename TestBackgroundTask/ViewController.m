//
//  ViewController.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import "AudioPlayerManager.h"

@interface ViewController ()

//Audio UI
@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UIButton *pauseBtn;
@property (nonatomic,strong)UIButton *stopBtn;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self testAudio];
}

- (void)testAudio {
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.pauseBtn];
    [self.view addSubview:self.stopBtn];
}

- (void)buildView {
    [self.view addSubview:self.playBtn];
}

#pragma mark setter and getter
- (UIButton *)playBtn {
    if (!_playBtn) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _playBtn = aButton;
        aButton.frame = CGRectMake(50, 100, 100, 100);
        [aButton setTitle:@"播放音乐" forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if (!_pauseBtn) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _pauseBtn = aButton;
        aButton.frame = CGRectMake(50, 250, 100, 100);
        [aButton setTitle:@"暂停音乐" forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseBtn;
}
- (UIButton *)stopBtn {
    if (!_stopBtn) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _stopBtn = aButton;
        aButton.frame = CGRectMake(50, 400, 100, 100);
        [aButton setTitle:@"结束音乐" forState:UIControlStateNormal];
        [aButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopBtn;
}

#pragma mark actions
-(void)play{
    [[AudioPlayerManager sharedManager] play];
}
-(void)pause{
    [[AudioPlayerManager sharedManager] pause];
}
-(void)stop{
    [[AudioPlayerManager sharedManager] stop];
}

@end
