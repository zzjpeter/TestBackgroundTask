//
//  AudioPlayerManager.h
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AVAudioPlayer;
@protocol AudioPlayerManagerDelegate <NSObject>

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end

@interface AudioPlayerManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic,assign)id<AudioPlayerManagerDelegate> delegate;

- (void)play;
- (void)pause;
- (void)stop;
- (void)fastForward;
- (void)rewind;
- (void)doubleRate;
- (void)volumeChange:(NSInteger)value;

- (void)setBackGroundPlay;

@end

NS_ASSUME_NONNULL_END
