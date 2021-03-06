//
//  ProtocolDataManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/25.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "HeaderInfo.h"
#import "ReqUpFileInfo.h"
#import "FileChunkInfo.h"
#import "CreatFolderInfo.h"
#import "MoveFolderInfo.h"
#import "FileListInfo.h"
#import "SourceModel.h"
#import "ReqDownFileInfo.h"
#import "DownFileInfo.h"
#import "EnumList.h"



@interface ProtocolDataManager : NSObject

+ (instancetype)sharedProtocolDataManager;


#pragma mark  客户端向服务器发送请求信息组装

//给真实数据添加协议头信息
- (NSData *)protocolDataWithCmd:(CmdType)cmd andData:(NSData *)data;

//注册信息组装 cmd1
- (NSData *)regDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd;

//登录信息组装 cmd2
- (NSData *)loginDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd;

//请求上传文件信息组装 cmd3
- (NSData *)reqUpFileDataWithFileName:(NSString *)fileName andDirectoryID:(u_short)directoryID andSize:(uint)size;

//上传文件包数据组装 cmd4
- (NSData *)upFileDataWithUserToken:(u_short)userToken andFileID:(u_short)fileID andChunks:(u_short)chunks andCurrentChunk:(u_short)chunk andDataSize:(u_short)size andSubFileData:(NSData *)subData;

//请求下载文件 cmd5
- (NSData *)reqDownFileDataWithUserToken:(u_short)userToken andFileName:(NSString *)fileName andDirectoryID:(u_short)directoryID;

//文件下载 cmd6
- (NSData *)downFileDataWithUserToken:(u_short)userToken andFileID:(u_short)fileID;

//请求创建文件夹  cmd7
- (NSData *)creatFolderWithToken:(u_short)userToken andDiretoryID:(u_short)diretoryID andDiretoryName:(NSString *)diretoryName;

//删除文件夹 cmd8
- (NSData *)moveFolderWithToken:(u_short)userToken andParentDiretoryID:(u_short)parentID andDiretoryID:(u_short )diretoryID;

//请求文件列表 cmd9
- (NSData *)fileListWithToken:(u_short)userToken andDirectoryID:(u_short)diretoryID;

#pragma mark  服务器封装响应数据给客户端

//给真实数据添加响应头信息
- (NSData *)resHeaderDataWithCmd:(Byte)cmd andResult:(Byte)result andData:(NSData *)data;

//注册响应信息组装
- (NSData *)resRegisterDataWithRet:(ResponsType)type;

//登录响应信息组装
- (NSData *)resLoginDataWithRet:(ResponsType)type andUserToken:(u_short)token;

//请求上传文件响应信息组装
- (NSData *)resReqUpFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID;

//文件上传信息组装
- (NSData *)resUpFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID;

//请求下载文件响应信息组装
- (NSData *)resReqDownFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID;

//文件下载响应信息组装
- (NSData *)resDownFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID andChunks:(u_short)chunks andCurrentChunk:(u_short)chunk andDataSize:(u_short)size andSubFileData:(NSData *)subData;

//创建文件夹响应
- (NSData *)resCreatDiretoryWithRet:(ResponsType)type;

//删除文件夹响应
- (NSData *)resMoveDiretoryWithRet:(ResponsType)type;

//文件列表响应
- (NSData *)resFileListWithRet:(ResponsType)type andParentID:(u_short)parentId andSourceModels:(NSArray *)models;

#pragma mark  服务器解析客服端请求的数据

//解析请求头信息
- (HeaderInfo *)getHeaderInfoWithData:(NSData *)data;

//解析用户名&密码信息
- (UserInfo *)getUserInfoWithData:(NSData *)data;

//解析请求上传文件信息
- (ReqUpFileInfo *)getReqFileInfoWithData:(NSData *)data;

//解析文件包信息
- (FileChunkInfo *)getFileChunkInfoWithData:(NSData *)data;

//解析请求下载文件信息
- (ReqDownFileInfo *)getReqDownFileInfoWithData:(NSData *)data;

//解析下载文件信息
- (DownFileInfo *)getDownFileInfoWithData:(NSData *)data;

//解析创建文件夹包信息
- (CreatFolderInfo *)getCreatFolderInfoWithData:(NSData *)data;

//解析删除文件夹包信息
- (MoveFolderInfo *)getMoveFolderInfoWithData:(NSData *)data;

//解析文件列表请求信息
- (FileListInfo *)getFileListInfoWithData:(NSData *)data;


#pragma mark  客服端解析服务器响应数据

//解析响应头信息
- (HeaderInfo *)getRespondHeaderInfoWithData:(NSData *)data;



@end
