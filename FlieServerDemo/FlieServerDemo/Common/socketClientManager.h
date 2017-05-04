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

typedef void(^GetGeneralDataBlock)(ResponsType replyType , u_short key);

@interface socketClientManager : NSObject

+(instancetype)sharedClientManager;

//链接服务器
- (BOOL)connectServer;

//断开服务
- (BOOL)disconnectServer;

//发送登录请求
- (void)sendLoginInfo:(UserInfo *)userInfo andBlock:(GetGeneralDataBlock )block;


@end
