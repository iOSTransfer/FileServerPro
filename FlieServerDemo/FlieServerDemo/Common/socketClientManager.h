//
//  socketClientManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/5/3.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface socketClientManager : NSObject

+(instancetype)sharedClientManager;

//链接服务器
- (BOOL)connectServer;

//断开服务
- (BOOL)disconnectServer;


@end
