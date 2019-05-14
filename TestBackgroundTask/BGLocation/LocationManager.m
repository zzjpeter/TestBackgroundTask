//
//  LocationManager.m
//  TestBackgroundTask
//
//  Created by 朱志佳 on 2019/5/14.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "BGTaskManager.h"

@interface LocationManager ()<CLLocationManagerDelegate>

@property (nonatomic,assign)BOOL isCollect;//是否正在定位（控制定位的开启和关闭，省电。。。）
@property (nonatomic,strong)CLLocationManager *locationManager;

@end

@implementation LocationManager

+ (instancetype)sharedManager {
    static LocationManager *manager = nil;
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
        self.isCollect = NO;
        //监听进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma mark setter and getter
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        _locationManager = locationManager;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.allowsBackgroundLocationUpdates = YES;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        locationManager.distanceFilter =kCLDistanceFilterNone;// 不移动也可以后台刷新回调（不移动就不会执行定位，不定位的话，那么后台进程也就挂起了，那么就不能执行任何操作）
        if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
            [locationManager requestAlwaysAuthorization];
        }
    }
    return _locationManager;
}

#pragma mark noti
//后台监听方法
-(void)applicationEnterBackground
{
    NSLog(@"come in background");
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"current thread:%@",[NSThread currentThread]);
    [self startLocation];
    [[BGTaskManager sharedManager] beginNewBackgroundTask];
    [[BGTaskManager sharedManager] startPrint];
}
- (void)applicationDidBecomeActive {
    NSLog(@"come in foreground");
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"current thread:%@",[NSThread currentThread]);
    [self stopLocation];
    [[BGTaskManager sharedManager] endBackGroundTask];
    [[BGTaskManager sharedManager] stopPrint];
}
#pragma mark 定位
//重启定位服务
- (void)restartLocation
{
    NSLog(@"重新启动定位");
    //NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    CLLocationManager *locationManager = self.locationManager;
    if([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [locationManager requestAlwaysAuthorization];//解决iOS 获取位置提示框不弹出
    }
    [locationManager startUpdatingLocation];
    [[BGTaskManager sharedManager] beginNewBackgroundTask];
}
//开启定位服务
- (void)startLocation{
    NSLog(@"开启定位");
    //NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = self.locationManager;
            if([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
    }
}

//停止后台定位
-(void)stopLocation
{
    NSLog(@"停止定位");
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [self.locationManager stopUpdatingLocation];
    self.isCollect = NO;
}

#pragma mark 定位delegate
//定位回调里执行重启定位和关闭定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"定位收集");
    //如果正在10秒定时收集的时间，不需要执行延时开启和关闭定位
    if (self.isCollect) {
        return;
    }
    [self performSelector:@selector(restartLocation) withObject:nil afterDelay:60 * 2];
    [self performSelector:@selector(stopLocation) withObject:nil afterDelay:10];
    self.isCollect = YES;//标记正在定位
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络连接" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请开启后台服务" message:@"应用没有不可以定位，需要在在设置/通用/后台应用刷新开启" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}

//判断定位权限
- (void)checkLocationAuthorization
{
    
    UIAlertView *alert;
    switch ([UIApplication sharedApplication].backgroundRefreshStatus) {
        case UIBackgroundRefreshStatusDenied:
        {
            alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"应用没有不可以定位，需要在在设置/通用/后台应用刷新开启" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case UIBackgroundRefreshStatusRestricted:
        {
            alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不可以定位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case UIBackgroundRefreshStatusAvailable:
        {
            
        }
            break;
        default:
            break;
    }
    
}

@end
