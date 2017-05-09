//
//  socketClientManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/5/3.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "EnumList.h"

#define GET_FILE_PROGRESS @"GET_FILE_PROGRESS"

@protocol socketClientManagerDelegate <NSObject>

@optional
- (void)receiveReplyType:(ResponsType )replyType andKey:(u_short)key  andCmd:(CmdType )cmd;

@end

typedef void(^GetGeneralDataBlock)(ResponsType replyType , u_short key);

@interface socketClientManager : NSObject

+(instancetype)sharedClientManager;

@property(weak , atomic)id<socketClientManagerDelegate> delegate;

//链接服务器
- (BOOL)connectServer;

//断开服务
- (BOOL)disconnectServer;

//发送数据
- (void)sendData:(NSData *)data;



@end
