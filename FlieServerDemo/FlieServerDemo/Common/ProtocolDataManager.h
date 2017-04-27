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

#import "EnumList.h"



@interface ProtocolDataManager : NSObject

+ (instancetype)sharedProtocolDataManager;


#pragma mark  请求部分拼装

//给真实数据添加协议头信息
- (NSData *)protocolDataWithCmd:(CmdType)cmd andData:(NSData *)data;

//注册信息组装
- (NSData *)regDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd;

//登录信息组装
- (NSData *)loginDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd;

//请求上传文件信息组装
- (NSData *)reqUpFileDataWithFileName:(NSString *)fileName andDirectoryID:(u_short)directoryID andSize:(uint)size;

//上传文件包数据组装
- (NSData *)upFileDataWithUserToken:(u_short)userToken andFileID:(u_short)fileID andChunks:(u_short)chunks andCurrentChunk:(u_short)chunk andDataSize:(u_short)size andSubFileData:(NSData *)subData;


#pragma mark  响应数据拼装

//给真实数据添加响应头信息
- (NSData *)resHeaderDataWithCmd:(Byte)cmd andResult:(Byte)result andData:(NSData *)data;

//注册响应信息组装
- (NSData *)resRegisterDataWithRet:(ResponsType)type;

//登录响应信息组装
- (NSData *)resLoginDataWithRet:(ResponsType)type andUserToken:(u_short)token;

//请求上传文件响应信息组装
- (NSData *)resReqUpFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID;

//文件上传信息组装
- (NSData *)resUpFileDataWithRet:(ResponsType)type;

#pragma mark  响应部分解析

//解析用户名&密码信息
- (HeaderInfo *)getHeaderInfoWithData:(NSData *)data;

//解析用户名&密码信息
- (UserInfo *)getUserInfoWithData:(NSData *)data;

//解析请求上传文件信息
- (ReqUpFileInfo *)getReqFileInfoWithData:(NSData *)data;

//解析文件包信息
- (FileChunkInfo *)getFileChunkInfoWithData:(NSData *)data;



@end
