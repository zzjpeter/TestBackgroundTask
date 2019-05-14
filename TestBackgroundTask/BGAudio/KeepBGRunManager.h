//
//  KeepBGRunManager.h
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeepBGRunManager : NSObject

+ (instancetype)sharedManager;
/**
 开启后台运行
 */
- (void)startBGRun;

/**
 关闭后台运行
 */
- (void)stopBGRun;

@end

NS_ASSUME_NONNULL_END
