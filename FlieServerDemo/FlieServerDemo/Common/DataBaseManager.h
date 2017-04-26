//
//  DataBaseManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/24.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReqUpFileInfo.h"
#import "EnumList.h"


@interface DataBaseManager : NSObject

+ (instancetype)sharedDataBase;

#pragma mark 用户信息表
//添加用户注册信息
- (NSData * )addUserInfoWithName:(NSString*)userName andPwd:(NSString*)password;

//客户端发送登录验证
- (NSData *)userLoginWithName:(NSString*)userName andPwd:(NSString*)password;


#pragma mark 文件信息表
//添加文件信息
- (NSData * )addFileInfoWithName:(ReqUpFileInfo *)upFileInfo;


@end
