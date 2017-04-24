//
//  NetWorkManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/24.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>


#define NetWorkDidChangeNotification @"NetWorkDidChangeNotification"    // 网络状态变化通知

@interface NetWorkManager : NSObject

+ (NetWorkManager *)shareNetWorkManager;

- (void)startListen;
- (void)stopListen;
- (BOOL)status;

@end
