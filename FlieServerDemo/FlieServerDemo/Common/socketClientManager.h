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

//发送登录请求
- (void)sendLoginInfo:(UserInfo *)userInfo;

//请求上传文件
- (void)sendReqFileupWithName:(NSString *)fileName andDirectoryID:(u_short)directoryID andSize:(uint)size;

//上传文件
- (void)sendFileDataWithUserToken:(u_short)userToken andFileID:(u_short)fileID andChunks:(u_short)chunks andCurrentChunk:(u_short)chunk andDataSize:(u_short)size andSubFileData:(NSData *)subData;


@end
