//
//  ProtocolDataManager.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/25.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ProtocolDataManager.h"


static ProtocolDataManager *_dataManager;



@implementation ProtocolDataManager

+ (instancetype)sharedProtocolDataManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _dataManager = [[self alloc]init];
        
    });
    return _dataManager;

}

#pragma mark  请求部分拼装

//给真实数据添加协议头信息
- (NSData *)protocolDataWithCmd:(CmdType)cmd andData:(NSData *)data
{
    Byte cmdByte = cmd;
    Byte ver = 1;
    Byte pad = 0;
    
    uint c_length = (uint)data.length;
    
    
    NSMutableData *muData = [NSMutableData data];
    
    
    [muData appendBytes:&cmdByte length:sizeof(Byte)];
    [muData appendBytes:&ver length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&c_length length:sizeof(uint)];
    [muData appendData:data];
    
    //分界
//    [muData appendData:[@"fff" dataUsingEncoding:4]];
    
    return [muData copy];
}

//注册信息组装
- (NSData *)regDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd
{
    
    NSData *userNameData = [userName dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    Byte userNameLength = (Byte)userNameData.length;
    Byte pwdLength = (Byte)pwdData.length;
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&userNameLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendData:userNameData];
    
    [muData appendBytes:&pwdLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendData:pwdData];
    
     return [self protocolDataWithCmd:CmdTypeReigter andData:muData];
    
}

//登录信息组装
- (NSData *)loginDataWithUserName:(NSString *)userName andPassword:(NSString *)pwd
{

    NSData *userNameData = [userName dataUsingEncoding:NSUTF8StringEncoding];
    NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    Byte userNameLength = (Byte)userNameData.length;
    Byte pwdLength = (Byte)pwdData.length;
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&userNameLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendData:userNameData];
    
    [muData appendBytes:&pwdLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendData:pwdData];
    
    return [self protocolDataWithCmd:CmdTypeLogin andData:muData];

}

//请求上传文件信息组装
- (NSData *)reqUpFileDataWithFileName:(NSString *)fileName andDirectoryID:(u_short)directoryID andSize:(uint)size
{
    u_short token = 1;
    
    NSData *fileNameData = [fileName dataUsingEncoding:NSUTF8StringEncoding];
    Byte fileNameLength = (Byte)fileNameData.length;
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&token length:sizeof(u_short)];
    [muData appendBytes:&fileNameLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendData:fileNameData];
    
    [muData appendBytes:&directoryID length:sizeof(u_short)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendBytes:&size length:sizeof(uint)];
    
    return [self protocolDataWithCmd:CmdTypeReqUp andData:muData];



}

//上传文件包数据组装
- (NSData *)upFileDataWithUserToken:(u_short)userToken andFileID:(u_short)fileID andChunks:(u_short)chunks andCurrentChunk:(u_short)chunk andDataSize:(u_short)size andSubFileData:(NSData *)subData
{
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    
    [muData appendBytes:&userToken length:sizeof(u_short)];
    [muData appendBytes:&fileID length:sizeof(u_short)];
    
    [muData appendBytes:&chunks length:sizeof(u_short)];
    [muData appendBytes:&chunk length:sizeof(u_short)];
    
    
    [muData appendBytes:&size length:sizeof(u_short)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendData:subData];

    return [self protocolDataWithCmd:CmdTypeUp andData:muData];
}

//请求下载文件
- (NSData *)reqDownFileDataWithUserToken:(u_short)userToken andFileName:(NSString *)fileName andDirectoryID:(u_short)directoryID
{
    NSData *fileNameData = [fileName dataUsingEncoding:NSUTF8StringEncoding];
    Byte fileNameLength = (Byte)fileNameData.length;
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&userToken length:sizeof(u_short)];
    [muData appendBytes:&fileNameLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendData:fileNameData];
    
    [muData appendBytes:&directoryID length:sizeof(u_short)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    return [self protocolDataWithCmd:CmdTypeReqDown andData:muData];
}

//文件下载
- (NSData *)downFileDataWithUserToken:(u_short)userToken andFileID:(u_short)fileID
{
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&userToken length:sizeof(u_short)];
    [muData appendBytes:&fileID length:sizeof(u_short)];

    return [self protocolDataWithCmd:CmdTypeDown andData:muData];
}

//请求创建文件夹
- (NSData *)creatFolderWithToken:(u_short)userToken andDiretoryID:(u_short)diretoryID andDiretoryName:(NSString *)diretoryName
{
    NSData *diretoryNameData = [diretoryName dataUsingEncoding:NSUTF8StringEncoding];
    
    Byte diretoryNameLength = (Byte)diretoryNameData.length;
    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    
    [muData appendBytes:&userToken length:sizeof(u_short)];
    [muData appendBytes:&diretoryID length:sizeof(u_short)];
    
    [muData appendBytes:&diretoryNameLength length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendData:diretoryNameData];
    
    return [self protocolDataWithCmd:CmdTypeAddFolder andData:muData];

}

//删除文件夹 cmd8
- (NSData *)moveFolderWithToken:(u_short)userToken andParentDiretoryID:(u_short)parentID andDiretoryID:(u_short)diretoryID
{

    Byte pad = 0;
    
    NSMutableData *muData = [NSMutableData data];
    
    [muData appendBytes:&userToken length:sizeof(u_short)];
    [muData appendBytes:&parentID length:sizeof(u_short)];
    
    [muData appendBytes:&diretoryID length:sizeof(u_short)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];

    
    return [self protocolDataWithCmd:CmdTypeRemoveFolder andData:muData];
}

//请求文件列表 cmd9
- (NSData *)fileListWithToken:(u_short)userToken andDirectoryID:(u_short)diretoryID
{
    NSMutableData *muData = [NSMutableData data];
    
    [muData appendBytes:&userToken length:sizeof(u_short)];
    [muData appendBytes:&diretoryID length:sizeof(u_short)];

    return [self protocolDataWithCmd:CmdTypeGetList andData:muData];
}

#pragma mark  响应数据拼装

//给真实数据添加响应头信息
- (NSData *)resHeaderDataWithCmd:(Byte)cmd andResult:(Byte)result andData:(NSData *)data
{
    Byte ver = 1;
    Byte pad = 0;
    uint r_length = (uint)data.length;
    
    
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&cmd length:sizeof(Byte)];
    [muData appendBytes:&result length:sizeof(Byte)];
    [muData appendBytes:&ver length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&r_length length:sizeof(uint)];
    [muData appendData:data];

    return [muData copy];

}

//注册响应信息组装
- (NSData *)resRegisterDataWithRet:(ResponsType)type
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    return [muData copy];
}

//登录响应信息组装
- (NSData *)resLoginDataWithRet:(ResponsType)type andUserToken:(u_short)token
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&token length:sizeof(u_short)];
    
    return [muData copy];



}

//请求上传文件响应信息组装
- (NSData *)resReqUpFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&fileID length:sizeof(u_short)];
    
    return [muData copy];

}

//文件上传信息组装
- (NSData *)resUpFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&fileID length:sizeof(u_short)];
 
    return [muData copy];
}

//请求下载文件响应信息组装
- (NSData *)resReqDownFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&fileID length:sizeof(u_short)];
    
    return [muData copy];

}

//文件下载响应信息组装
- (NSData *)resDownFileDataWithRet:(ResponsType)type andFileID:(u_short)fileID andChunks:(u_short)chunks andCurrentChunk:(u_short)chunk andDataSize:(u_short)size andSubFileData:(NSData *)subData
{
    Byte pad = 0;

    NSMutableData *muData = [NSMutableData data];
    
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&fileID length:sizeof(u_short)];
    
    [muData appendBytes:&chunks length:sizeof(u_short)];
    [muData appendBytes:&chunk length:sizeof(u_short)];
    
    
    [muData appendBytes:&size length:sizeof(u_short)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    [muData appendData:subData];
    
    return [muData copy];


}

//创建文件夹响应
- (NSData *)resCreatDiretoryWithRet:(ResponsType)type
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    return [muData copy];
}

//删除文件夹响应
- (NSData *)resMoveDiretoryWithRet:(ResponsType)type
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    
    return [muData copy];
}

//文件列表响应
- (NSData *)resFileListWithRet:(ResponsType)type andParentID:(u_short)parentId andSourceModels:(NSArray *)models
{
    Byte pad = 0;
    NSMutableData *muData = [NSMutableData data];
    
    [muData appendBytes:&type length:sizeof(Byte)];
    [muData appendBytes:&pad length:sizeof(Byte)];
    [muData appendBytes:&parentId length:sizeof(u_short)];
    
    for (SourceModel *model in models) {
        Byte type = model.type;
        u_short sourceID = model.sourceID;
        [muData appendBytes:&type length:sizeof(Byte)];
        [muData appendBytes:&sourceID length:sizeof(u_short)];
        
        NSData *nameData = [model.sourceName dataUsingEncoding:NSUTF8StringEncoding];
        Byte nameLength = (Byte)nameData.length;
        [muData appendBytes:&nameLength length:sizeof(Byte)];
        [muData appendData:nameData];
    }
    
    return [muData copy];
}


#pragma mark  请求体解析

//解析Header信息
- (HeaderInfo *)getHeaderInfoWithData:(NSData *)data
{
    Byte cmdByte;
    Byte ver;
    
    uint c_length;

    [[data subdataWithRange:NSMakeRange(0, 1)] getBytes:&cmdByte length:sizeof(Byte)];
    [[data subdataWithRange:NSMakeRange(1, 1)] getBytes:&ver length:sizeof(Byte)];
    [[data subdataWithRange:NSMakeRange(4, 4)] getBytes:&c_length length:sizeof(uint)];
    
    HeaderInfo *header = [HeaderInfo new];
    header.cmd = cmdByte;
    header.ver = ver;
    header.c_length = c_length;
    
    
    return header;
}

//解析用户名&密码信息
- (UserInfo *)getUserInfoWithData:(NSData *)data
{
    
    UserInfo *user = [[UserInfo alloc]init];
    
    Byte userNameLength;
    [[data subdataWithRange:NSMakeRange(0, 1)] getBytes:&userNameLength length:sizeof(Byte)];
    
    user.userName  =[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, userNameLength)]  encoding:NSUTF8StringEncoding];
    
    Byte pwdLength;
    [[data subdataWithRange:NSMakeRange(4 + userNameLength, 1)] getBytes:&pwdLength length:sizeof(Byte)];
    
    user.userPwd = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange( userNameLength + 4 + 4, pwdLength)]  encoding:NSUTF8StringEncoding];
    

    return user;
}

//解析请求上传文件信息
- (ReqUpFileInfo *)getReqFileInfoWithData:(NSData *)data
{
    ReqUpFileInfo *reqInfo = [ReqUpFileInfo new];
    u_short userToken;
    [[data subdataWithRange:NSMakeRange(0, 2)] getBytes:&userToken length:sizeof(u_short)];
    reqInfo.userToken = userToken;
    
    Byte fileNameLength;
    [[data subdataWithRange:NSMakeRange(2, 1)] getBytes:&fileNameLength length:sizeof(Byte)];
    reqInfo.fileNameLength = fileNameLength;
    
    reqInfo.fileName  =[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, fileNameLength)]  encoding:NSUTF8StringEncoding];
    
    u_short directoryID;
    [[data subdataWithRange:NSMakeRange(fileNameLength + 4, 2)] getBytes:&directoryID length:sizeof(u_short)];
    reqInfo.directoryID = directoryID;

    
    uint size;
    [[data subdataWithRange:NSMakeRange(fileNameLength + 4 + 4 , 4)] getBytes:&size length:sizeof(uint)];
    reqInfo.size = size;
    
    
    return reqInfo;
}

//解析文件包信息
- (FileChunkInfo *)getFileChunkInfoWithData:(NSData *)data
{
    FileChunkInfo *chunkInfo = [FileChunkInfo new];
    
    u_short userToken;
    [[data subdataWithRange:NSMakeRange(0, 2)] getBytes:&userToken length:sizeof(u_short)];
    chunkInfo.userToken = userToken;
    
    u_short fileID;
    [[data subdataWithRange:NSMakeRange(2, 2)] getBytes:&fileID length:sizeof(u_short)];
    chunkInfo.fileID = fileID;
    
    u_short chunks;
    [[data subdataWithRange:NSMakeRange(4, 2)] getBytes:&chunks length:sizeof(u_short)];
    chunkInfo.chunks = chunks;
    
    u_short chunk;
    [[data subdataWithRange:NSMakeRange(6, 2)] getBytes:&chunk length:sizeof(u_short)];
    chunkInfo.chunk = chunk;
    
    u_short size;
    [[data subdataWithRange:NSMakeRange(8, 2)] getBytes:&size length:sizeof(u_short)];
    chunkInfo.size = size;
    
    chunkInfo.subData = [data subdataWithRange:NSMakeRange(12, size)];
    
    return chunkInfo;
}

//解析请求下载文件信息
- (ReqDownFileInfo *)getReqDownFileInfoWithData:(NSData *)data
{
    ReqDownFileInfo *reqInfo = [ReqDownFileInfo new];
    u_short userToken;
    [[data subdataWithRange:NSMakeRange(0, 2)] getBytes:&userToken length:sizeof(u_short)];
    reqInfo.userToken = userToken;
    
    Byte fileNameLength;
    [[data subdataWithRange:NSMakeRange(2, 1)] getBytes:&fileNameLength length:sizeof(Byte)];
    reqInfo.fileNameLength = fileNameLength;
    
    reqInfo.fileName  =[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, fileNameLength)]  encoding:NSUTF8StringEncoding];
    
    u_short directoryID;
    [[data subdataWithRange:NSMakeRange(fileNameLength + 4, 2)] getBytes:&directoryID length:sizeof(u_short)];
    reqInfo.directoryID = directoryID;
    
 
    return reqInfo;
}

//解析下载文件信息
- (DownFileInfo *)getDownFileInfoWithData:(NSData *)data
{
    DownFileInfo *downInfo = [DownFileInfo new];
    u_short userToken;
    u_short fileID;
    [[data subdataWithRange:NSMakeRange(0, 2)] getBytes:&userToken length:sizeof(u_short)];
    [[data subdataWithRange:NSMakeRange(2, 2)] getBytes:&fileID length:sizeof(u_short)];
    
    downInfo.userToken = userToken;
    downInfo.fileID = fileID;
    
    return downInfo;
}

//解析创建文件夹包信息
- (CreatFolderInfo *)getCreatFolderInfoWithData:(NSData *)data
{
    CreatFolderInfo *creatInfo = [CreatFolderInfo new];
    
    u_short userToken;
    [[data subdataWithRange:NSMakeRange(0, 2)] getBytes:&userToken length:sizeof(u_short)];
    creatInfo.userToken = userToken;
    
    u_short diretoryID;
    [[data subdataWithRange:NSMakeRange(2, 2)] getBytes:&diretoryID length:sizeof(u_short)];
    creatInfo.diretoryID = diretoryID;
    
    Byte nameLength;
    [[data subdataWithRange:NSMakeRange(4, 1)] getBytes:&nameLength length:sizeof(Byte)];
    creatInfo.nameLength = nameLength;
    
    creatInfo.diretoryName = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(8, nameLength)]  encoding:NSUTF8StringEncoding];
    
    return creatInfo;
}

//解析删除文件夹包信息
- (MoveFolderInfo *)getMoveFolderInfoWithData:(NSData *)data
{
    MoveFolderInfo *moveInfo = [MoveFolderInfo new];
    
    u_short userToken;
    [[data subdataWithRange:NSMakeRange(0, 2)] getBytes:&userToken length:sizeof(u_short)];
    moveInfo.userToken = userToken;
    
    u_short parentID;
    [[data subdataWithRange:NSMakeRange(2, 2)] getBytes:&parentID length:sizeof(u_short)];
    moveInfo.parentID = parentID;
    
    u_short diretoryID;
    [[data subdataWithRange:NSMakeRange(4, 2)] getBytes:&diretoryID length:sizeof(u_short)];
    moveInfo.diretoryID = diretoryID;
    

    return moveInfo;


}

//解析文件列表请求信息
- (FileListInfo *)getFileListInfoWithData:(NSData *)data
{
    FileListInfo *listInfo = [FileListInfo new];
    
    u_short userToken;
    [[data subdataWithRange:NSMakeRange(0, 2)] getBytes:&userToken length:sizeof(u_short)];
    listInfo.userToken = userToken;
    
    u_short diretoryID;
    [[data subdataWithRange:NSMakeRange(2, 2)] getBytes:&diretoryID length:sizeof(u_short)];
    listInfo.directoryID = diretoryID;
    
    return listInfo;
}






@end
