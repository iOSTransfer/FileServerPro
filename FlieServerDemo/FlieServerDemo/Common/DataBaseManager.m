//
//  DataBaseManager.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/24.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDB.h"

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
    NSLog(@"%@",filePath);
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
    // 初始化数据表
    
    //1.用户表
    NSString *userSql = @"CREATE TABLE 'user' ('user_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'user_name' VARCHAR(255) NOT NULL UNIQUE,'user_password' VARCHAR(255) NOT NULL )";
    
    //2.文件表
//    NSString *fileSql = @"CREATE TABLE 'file' ('user_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'user_name' VARCHAR(255) NOT NULL,'user_password' VARCHAR(255) NOT NULL )";
    
    
    BOOL exeType = [_db executeUpdate:userSql];
    if (exeType) {
        NSLog(@"user表创建成功");
    }
    
    [_db close];
    
}

#pragma mark 用户信息表

//添加用户注册信息
- (BOOL)addUserInfoWithName:(NSString*)userName andPwd:(NSString*)password
{
    [_db open];
    BOOL isSucceed = [_db executeUpdate:@"INSERT INTO user(user_name,user_password)VALUES(?,?)",userName,password];
    [_db close];
    
    
    return isSucceed;
}











@end
