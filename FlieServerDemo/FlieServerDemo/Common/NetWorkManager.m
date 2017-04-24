//
//  NetWorkManager.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/24.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "NetWorkManager.h"
#import "AFNetworkReachabilityManager.h"

static NetWorkManager *_networkManager;

@implementation NetWorkManager

+ (NetWorkManager *)shareNetWorkManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _networkManager = [[self alloc]init];
        
    });
    return _networkManager;

}


- (instancetype)init {
    if (self = [super init]) {
        // 网络状态监听
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                NSLog(@"有网络");
                [[NSNotificationCenter defaultCenter] postNotificationName:NetWorkDidChangeNotification object:nil userInfo:@{@"status": [NSNumber numberWithBool:true]}];
            } else {
                NSLog(@"无网络");
                [[NSNotificationCenter defaultCenter] postNotificationName:NetWorkDidChangeNotification object:nil userInfo:@{@"status": [NSNumber numberWithBool:false]}];
            }
        }];
    }
    return self;
}

- (void)startListen
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)stopListen
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (BOOL)status
{
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
        return true;
    }
    return false;
}




@end
