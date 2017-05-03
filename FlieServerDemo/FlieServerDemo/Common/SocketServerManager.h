//
//  SocketServerManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/5/3.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFIER_STRING @"UPADTE_SOCKET_COUNTS"

@interface SocketServerManager : NSObject

+(instancetype)sharedServerManager;

//开启服务
- (BOOL)openServer;

//关闭服务
- (BOOL)closeServer;

@end
