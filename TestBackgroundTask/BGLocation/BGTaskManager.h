//
//  BGTaskManager.h
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface BGTaskManager : NSObject

+ (instancetype)sharedManager;
-(UIBackgroundTaskIdentifier)beginNewBackgroundTask; //开启新的后台任务
-(void)endBackGroundTask;//结束后台任务

//打印和资源释放相关
- (void)startPrint;
- (void)stopPrint;

@end

NS_ASSUME_NONNULL_END
