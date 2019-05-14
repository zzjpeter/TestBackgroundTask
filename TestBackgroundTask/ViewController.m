//
//  ViewController.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong)NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testTask];
}

- (void)testTask {
    //[self timer];
}

#pragma mark timer
- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
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
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
