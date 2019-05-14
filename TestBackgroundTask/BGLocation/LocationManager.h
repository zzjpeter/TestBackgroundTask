//
//  LocationManager.h
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : NSObject

+ (instancetype)sharedManager;

- (void)startLocation;

//判断定位权限
- (void)checkLocationAuthorization;

@end

NS_ASSUME_NONNULL_END
