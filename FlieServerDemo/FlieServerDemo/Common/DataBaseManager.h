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
#import "DownFileInfo.h"
#import "EnumList.h"


typedef void(^ResultBlock)(NSData *replyData,ResponsType resType);

@interface DataBaseManager : NSObject

+ (instancetype)sharedDataBase;

#pragma mark 用户信息表
//添加用户注册信息
- (void)addUserInfoWithName:(NSString*)userName andPwd:(NSString*)password withResultBlock:(ResultBlock)block;

//客户端发送登录验证
- (void)userLoginWithName:(NSString*)userName andPwd:(NSString*)password withResultBlock:(ResultBlock)block;


#pragma mark 文件信息表
//添加文件信息
- (void)addFileInfoWithName:(ReqUpFileInfo *)upFileInfo withResultBlock:(ResultBlock)block;

//分发文件数据包
- (void)cachesSubFileDataWith:(FileChunkInfo *)fileChunkInfo withResultBlock:(ResultBlock)block;

//查询文件是否存在
- (void)queryFileWith:(ReqDownFileInfo *)reqDownInfo withResultBlock:(ResultBlock)block;

//创建一个文件夹
- (void)addFolderWith:(CreatFolderInfo *)folderInfo withResultBlock:(ResultBlock)block;

//文件下载
- (void)getFileDataWith:(DownFileInfo *)downFileInfo withResultBlock:(void(^)(NSArray *replyDatas,ResponsType resType))block;

//删除一个文件夹
- (void)moveFolderWith:(MoveFolderInfo *)folderInfo withResultBlock:(ResultBlock)block;

//获取文件列表 
- (void)getFileListWith:(FileListInfo *)fileListInfo withResultBlock:(ResultBlock)block;


@end
