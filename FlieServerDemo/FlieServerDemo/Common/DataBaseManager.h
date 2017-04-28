//
//  DataBaseManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/24.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReqUpFileInfo.h"
#import "FileChunkInfo.h"
#import "CreatFolderInfo.h"
#import "MoveFolderInfo.h"
#import "FileListInfo.h"
#import "SourceModel.h"
#import "ReqDownFileInfo.h"

#import "EnumList.h"


@interface DataBaseManager : NSObject

+ (instancetype)sharedDataBase;

#pragma mark 用户信息表
//添加用户注册信息 & 返回响应二进制数据
- (NSData *)addUserInfoWithName:(NSString*)userName andPwd:(NSString*)password;

//客户端发送登录验证 & 返回响应二进制数据
- (NSData *)userLoginWithName:(NSString*)userName andPwd:(NSString*)password;


#pragma mark 文件信息表
//添加文件信息
- (NSData *)addFileInfoWithName:(ReqUpFileInfo *)upFileInfo;

//分发文件数据包
- (NSData *)cachesSubFileDataWith:(FileChunkInfo *)fileChunkInfo;

//查询文件是否存在
- (NSData *)queryFileWith:(ReqDownFileInfo *)reqDownInfo;

//创建一个文件夹
- (NSData *)addFolderWith:(CreatFolderInfo *)folderInfo;

//删除一个文件夹
- (NSData *)moveFolderWith:(MoveFolderInfo *)folderInfo;

//获取文件列表 
- (NSData *)getFileListWith:(FileListInfo *)fileListInfo;


@end
