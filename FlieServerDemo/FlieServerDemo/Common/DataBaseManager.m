//
//  DataBaseManager.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/24.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDB.h"
#import "ProtocolDataManager.h"
#import "AppDataSource.h"

#define DEVICE_TABLE_NAME @"user"

static DataBaseManager *_dbManager;


@interface DataBaseManager(){
    FMDatabase  *_db;
}


@end


@implementation DataBaseManager



+ (instancetype)sharedDataBase
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _dbManager = [[self alloc]init];
        [_dbManager initDataBase];
        
    });
    return _dbManager;
    
}

//初始化数据库&建表
- (void)initDataBase
{
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"fileServer.sql"];
    NSLog(@"数据库文件地址 -- %@",filePath);
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
    // 初始化数据表
    
    //1.用户表
    NSString *userSql = @"CREATE TABLE IF NOT EXISTS 'user' ('user_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'user_name' VARCHAR(255) NOT NULL UNIQUE,'user_password' VARCHAR(255) NOT NULL )";
    
    //2.文件表
    NSString *fileSql = @"CREATE TABLE IF NOT EXISTS 'file' ('file_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'file_name' VARCHAR(255) NOT NULL,'file_size' VARCHAR(255) ,'directory_id' INTEGER )";
    
    //3.文件夹表
    NSString *directorySql = @"CREATE TABLE IF NOT EXISTS 'directory' ('directory_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'directory_name' VARCHAR(255) NOT NULL ,'parent_id' INTEGER )";
    
    
    BOOL exeType  =  [_db executeUpdate:userSql];
    BOOL fileType  =  [_db executeUpdate:fileSql];
    BOOL directoryType  =  [_db executeUpdate:directorySql];
    
    [_db close];
    
    if (exeType) {
        NSLog(@"user表创建成功");
    }
    
    if (fileType) {
        NSLog(@"file表创建成功");
    }
    
    if (directoryType) {
        NSLog(@"directory表创建成功");
    }
    
}

#pragma mark 用户信息表

//添加用户注册信息
- (NSData *)addUserInfoWithName:(NSString*)userName andPwd:(NSString*)password
{
    if (userName.length < 1 || password.length < 1 ) {
        return [[ProtocolDataManager sharedProtocolDataManager] resRegisterDataWithRet:ResponsTypeRegisterNull];
    }

    [_db open];
    BOOL isSucceed = [_db executeUpdate:@"INSERT INTO user(user_name,user_password)VALUES(?,?)",userName,password];
    [_db close];
    
    if (isSucceed) {
        return [[ProtocolDataManager sharedProtocolDataManager] resRegisterDataWithRet:ResponsTypeRegisterSuccess];
    }else{
        return [[ProtocolDataManager sharedProtocolDataManager] resRegisterDataWithRet:ResponsTypeRegisterExist];
    }
 
}

//客户端发送登录验证
- (NSData *)userLoginWithName:(NSString*)userName andPwd:(NSString*)password
{
    if (userName.length < 1 || password.length < 1 ) {
        
        return [[ProtocolDataManager sharedProtocolDataManager] resLoginDataWithRet:ResponsTypeLoginError andUserToken:0];
    }
    
    [_db open];
    
    FMResultSet *res = [_db executeQuery:@"SELECT user_id FROM user WHERE user_name = ? and user_password = ?",userName,password];
    u_short userToken = 0;
    
    while ([res next]) {
        userToken  = (u_short)[res intForColumn:@"user_id"];
    }
    
    [_db close];
    
    if (userToken) {
        NSNumber *token = [NSNumber numberWithUnsignedShort:userToken];
        if ([[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
            
            return [[ProtocolDataManager sharedProtocolDataManager] resLoginDataWithRet:ResponsTypeLoginExist andUserToken:0];
            
        }else{
            [[AppDataSource shareAppDataSource].currentUsers addObject:token];
            return [[ProtocolDataManager sharedProtocolDataManager] resLoginDataWithRet:ResponsTypeLoginSuccess andUserToken:userToken];
        }
        
        
    }else{
        return [[ProtocolDataManager sharedProtocolDataManager] resLoginDataWithRet:ResponsTypeLoginError andUserToken:0];
    
    }

}


#pragma mark 文件信息表 & 文件夹信息表
//添加文件信息
- (NSData * )addFileInfoWithName:(ReqUpFileInfo *)upFileInfo
{
    //文件名称不能为空
    if (upFileInfo.fileNameLength < 1) {
        return [[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpFileNameNull andFileID:0];
    }
    
    //未登录,无权限下载
    NSNumber *token = [NSNumber numberWithUnsignedShort:upFileInfo.userToken];
    if ([[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        return [[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpNo andFileID:0];
    }
    
    //服务器空间不足
    if (upFileInfo.size > [[AppDataSource shareAppDataSource] freeDiskSpaceInBytes]) {
        return [[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpFull andFileID:0];
    }

    //文件夹不存在
    [_db open];
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM directory WHERE directory_id = ?",@(upFileInfo.directoryID)];
    BOOL isExist = NO;
    while ([res next]) {
        isExist = YES;
    }
    if (!isExist) {
        [_db close];
        return [[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpNoFolder andFileID:0];
    }
    
    //文件名称不相同
    FMResultSet *res2 = [_db executeQuery:@"SELECT * FROM file WHERE file_name = ? AND directory_id = ? ",upFileInfo.fileName,@(upFileInfo.directoryID)];
    
    BOOL isExistFile = NO;
    while ([res2 next]) {
        isExistFile = YES;
    }
    if (isExistFile) {
        [_db close];
        return [[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpFileExist andFileID:0];
    }
    
    //开始插入数据
    BOOL isSucceed = [_db executeUpdate:@"INSERT INTO file(file_name,file_size,directory_id)VALUES(?,?,?)",upFileInfo.fileName,upFileInfo.size,@(upFileInfo.directoryID)];
    
    if (isSucceed) {
        FMResultSet *res3 = [_db executeQuery:@"SELECT * FROM file WHERE file_name = ? AND directory_id = ? ",upFileInfo.fileName,@(upFileInfo.directoryID)];
        u_short fileID = 0;
        while ([res3 next]) {
            fileID = (u_short)[res3 intForColumn:@"file_id"];
        }
        
        return [[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpSuccess andFileID:fileID];
    }else{
       return [[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpFileExist andFileID:0];
    }
}






@end
