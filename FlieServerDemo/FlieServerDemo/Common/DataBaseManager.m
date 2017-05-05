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
#import "FileHandleModel.h"


#define MainLib [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Main"]
#define TmpLib [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Tmp"]

#define DEVICE_TABLE_NAME @"user"

static DataBaseManager *_dbManager;


@interface DataBaseManager(){
    FMDatabase  *_db;
//    NSFileHandle *_writeHandle;
}

@property (nonatomic ,strong)NSMutableArray *receiveDataChunks;
@property (nonatomic ,strong)NSMutableSet *waitingUpFileIDs;  //等待上传文件的文件ID
@property (nonatomic ,strong)NSMutableArray *keyHandles;

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

- (NSMutableArray *)receiveDataChunks
{
    if (!_receiveDataChunks) {
        _receiveDataChunks = [[NSMutableArray alloc]init];
    }
    return _receiveDataChunks;
}

- (NSMutableArray *)keyHandles
{
    if (!_keyHandles) {
        _keyHandles = [[NSMutableArray alloc]init];
    }
    return _keyHandles;
}

- (NSMutableSet *)waitingUpFileIDs
{
    if (!_waitingUpFileIDs) {
        _waitingUpFileIDs = [[NSMutableSet alloc]init];
        [_waitingUpFileIDs addObject:[NSNumber numberWithInt:1]];
        [_waitingUpFileIDs addObject:[NSNumber numberWithInt:2]];
    }
    return _waitingUpFileIDs;
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
    NSString *fileSql = @"CREATE TABLE IF NOT EXISTS 'file' ('file_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'file_name' VARCHAR(255) NOT NULL,'file_size' INTEGER NOT NULL,'directory_id' INTEGER NOT NULL,'user_id' INTEGER NOT NULL , 'file_state' INTEGER default 0)";
    
    //3.文件夹表
    NSString *directorySql = @"CREATE TABLE IF NOT EXISTS 'directory' ('directory_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'directory_name' VARCHAR(255) NOT NULL ,'parent_id' INTEGER )";
    
    
    BOOL exeType  =  [_db executeUpdate:userSql];
    BOOL fileType  =  [_db executeUpdate:fileSql];
    BOOL directoryType  =  [_db executeUpdate:directorySql];
    
    //初始化数据
    BOOL addFolder  =  [_db executeUpdate:@"INSERT INTO directory(directory_id,directory_name,parent_id)VALUES(?,?,?)",@(1),@"main",@(0)];
    
    if (exeType) {
        NSLog(@"user表创建成功");
    }
    
    if (fileType) {
        NSLog(@"file表创建成功");
    }
    
    if (directoryType && addFolder) {
        NSLog(@"directory表创建成功");
    }
    
}

#pragma mark 用户信息表

//添加用户注册信息
- (void)addUserInfoWithName:(NSString*)userName andPwd:(NSString*)password withResultBlock:(ResultBlock)block
{
    if (userName.length < 1 || password.length < 1 ) {
        block([[ProtocolDataManager sharedProtocolDataManager] resRegisterDataWithRet:ResponsTypeRegisterNull],ResponsTypeRegisterNull);
        return;
    }

    
    BOOL isSucceed = [_db executeUpdate:@"INSERT INTO user(user_name,user_password)VALUES(?,?)",userName,password];
    
    if (isSucceed) {
        block([[ProtocolDataManager sharedProtocolDataManager] resRegisterDataWithRet:ResponsTypeRegisterSuccess],ResponsTypeRegisterSuccess);
    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resRegisterDataWithRet:ResponsTypeRegisterExist],ResponsTypeRegisterExist);
    }
 
}

//客户端发送登录验证
- (void)userLoginWithName:(NSString*)userName andPwd:(NSString*)password withResultBlock:(ResultBlock)block
{
    if (userName.length < 1 || password.length < 1 ) {
        
        block([[ProtocolDataManager sharedProtocolDataManager] resLoginDataWithRet:ResponsTypeLoginError andUserToken:0],ResponsTypeLoginError);
        return;
    }
    
    FMResultSet *res = [_db executeQuery:@"SELECT user_id FROM user WHERE user_name = ? and user_password = ?",userName,password];
    u_short userToken = 0;
    
    while ([res next]) {
        userToken  = (u_short)[res intForColumn:@"user_id"];
    }
    
    if (userToken) {
        NSNumber *token = [NSNumber numberWithUnsignedShort:userToken];
        if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
            [[AppDataSource shareAppDataSource].currentUsers addObject:token];
        }
        
        block([[ProtocolDataManager sharedProtocolDataManager] resLoginDataWithRet:ResponsTypeLoginSuccess andUserToken:userToken],ResponsTypeLoginSuccess);
    
    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resLoginDataWithRet:ResponsTypeLoginError andUserToken:0],ResponsTypeLoginError);
    
    }

}


#pragma mark 文件信息表 & 文件夹信息表
//添加文件信息
- (void)addFileInfoWithName:(ReqUpFileInfo *)upFileInfo withResultBlock:(ResultBlock)block
{
    //文件名称不能为空
    if (upFileInfo.fileNameLength < 1) {
        block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpFileNameNull andFileID:0],ResponsTypeReqUpFileNameNull);
        return;
    }
    
    //未登录
    NSNumber *token = [NSNumber numberWithUnsignedShort:upFileInfo.userToken];
    if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeNoLogin andFileID:0],ResponsTypeNoLogin);
        return;
    }
    
    //服务器空间不足
    if (upFileInfo.size > [[AppDataSource shareAppDataSource] freeDiskSpaceInBytes]) {
        block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpFull andFileID:0],ResponsTypeReqUpFull);
        return ;
    }

    //文件夹不存在
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM directory WHERE directory_id = ?",@(upFileInfo.directoryID)];
    BOOL isExist = NO;
    while ([res next]) {
        isExist = YES;
    }
    if (!isExist) {
        block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpNoFolder andFileID:0],ResponsTypeReqUpNoFolder);
        return;
    }
    
    //文件名称不相同,每个文件，对应一个用户
    FMResultSet *res2 = [_db executeQuery:@"SELECT * FROM file WHERE file_name = ? AND directory_id = ? ",upFileInfo.fileName,@(upFileInfo.directoryID)];
    
    BOOL isExistFile = NO;
    u_short user_id = 0;
    u_short file_id = 0;
    while ([res2 next]) {
        user_id = (u_short)[res2 intForColumn:@"user_id"];
        file_id = (u_short)[res2 intForColumn:@"file_id"];
        isExistFile = YES;
    }
    
    if (isExistFile) {

        if (user_id == upFileInfo.userToken) {
            
            //缓存可以上传文件的文件ID
            NSNumber *fileNumber = [NSNumber numberWithUnsignedShort:file_id];
            [self.waitingUpFileIDs addObject:fileNumber];
            block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpSuccess andFileID:file_id],ResponsTypeReqUpSuccess);
            return;
           
        }else{
            block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpFileExist andFileID:0],ResponsTypeReqUpFileExist);
            return;
        
        }
        
    }
    
    //开始插入数据
    BOOL isSucceed = [_db executeUpdate:@"INSERT INTO file(file_name,file_size,directory_id,user_id)VALUES(?,?,?,?)",upFileInfo.fileName,@(upFileInfo.size),@(upFileInfo.directoryID),@(upFileInfo.userToken)];
    
    if (isSucceed) {
        FMResultSet *res3 = [_db executeQuery:@"SELECT * FROM file WHERE file_name = ? AND directory_id = ? AND user_id = ? ",upFileInfo.fileName,@(upFileInfo.directoryID),@(upFileInfo.userToken)];
        u_short fileID = 0;
        while ([res3 next]) {
            fileID = (u_short)[res3 intForColumn:@"file_id"];
        }
        //缓存可以上传文件的文件ID
        NSNumber *fileNumber = [NSNumber numberWithUnsignedShort:fileID];
        [self.waitingUpFileIDs addObject:fileNumber];
        block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeReqUpSuccess andFileID:fileID],ResponsTypeReqUpSuccess);
    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resReqUpFileDataWithRet:ResponsTypeServerError andFileID:0],ResponsTypeServerError);
    }
}

//分发文件数据包 & 返回响应二进制数据
- (void)cachesSubFileDataWith:(FileChunkInfo *)fileChunkInfo withResultBlock:(ResultBlock)block
{
    //未登录
    NSNumber *token = [NSNumber numberWithUnsignedShort:fileChunkInfo.userToken];
    if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        block([[ProtocolDataManager sharedProtocolDataManager] resUpFileDataWithRet:ResponsTypeNoLogin andFileID:fileChunkInfo.fileID],ResponsTypeNoLogin);
        return;
    }
    
    //验证文件的ID
    NSNumber *fileID = [NSNumber numberWithUnsignedShort:fileChunkInfo.fileID];
    if ([self.waitingUpFileIDs containsObject:fileID]) {
        
        FMResultSet *res = [_db executeQuery:@"SELECT * FROM file WHERE file_id = ? ",@(fileChunkInfo.fileID)];
        
        BOOL isExistFile = NO;
        NSString *fileName;
        Byte state = 0;
        while ([res next]) {
            fileName = [res stringForColumn:@"file_name"];
            state = (Byte)[res intForColumn:@"file_state"];
            isExistFile = YES;
        }
        
        if (fileName == nil) {
            block([[ProtocolDataManager sharedProtocolDataManager] resUpFileDataWithRet:ResponsTypeServerError andFileID:fileChunkInfo.fileID],ResponsTypeServerError);
            return;
        }
        
        if (fileName != nil && state) {
            block([[ProtocolDataManager sharedProtocolDataManager] resUpFileDataWithRet:ResponsTypeUpFileExist andFileID:fileChunkInfo.fileID],ResponsTypeUpFileExist);
            return;
        }

        // 文件路径
        NSString *cachesPath = [TmpLib stringByAppendingPathComponent:fileName];
        NSLog(@"%@",cachesPath);
        
        // 创建一个空的文件到沙盒中
        NSFileManager* mgr = [NSFileManager defaultManager];
        [mgr removeItemAtPath:cachesPath error:nil];
        [mgr createFileAtPath:cachesPath contents:nil attributes:nil];
        
        FileHandleModel *handelModel = [FileHandleModel new];
        handelModel.fileID = fileChunkInfo.fileID;
        handelModel.fileHandle = [NSFileHandle fileHandleForWritingAtPath:cachesPath];
        handelModel.filePath = cachesPath;
        handelModel.toFilePath = [MainLib stringByAppendingPathComponent:fileName];
        
        [self.keyHandles addObject:handelModel];
        
        [self.waitingUpFileIDs removeObject:fileID];

    }

    
    
    if (self.keyHandles.count  < 1 ) {
        block([[ProtocolDataManager sharedProtocolDataManager] resUpFileDataWithRet:ResponsTypeUpError andFileID:fileChunkInfo.fileID],ResponsTypeUpError);
        return;
    }
    
    FileHandleModel *currentHandle;
    for (FileHandleModel *model in self.keyHandles) {
        if (model.fileID == fileChunkInfo.fileID) {
            currentHandle = model;
            break;
        }
        
    }
    
    if (currentHandle == nil) {
        
    }
    
    [currentHandle.fileHandle seekToEndOfFile];
    
    [currentHandle.fileHandle writeData:fileChunkInfo.subData];
        
        
    if (fileChunkInfo.chunks == fileChunkInfo.chunk) {
        
        NSError *err;
        BOOL isSuccess = [[NSFileManager defaultManager] moveItemAtPath:currentHandle.filePath toPath:currentHandle.toFilePath error:&err];
        [currentHandle.fileHandle closeFile];
        [self.keyHandles removeObject:currentHandle];
        
        BOOL success = [_db executeUpdate:@"UPDATE 'file' SET file_state = ?  WHERE file_id = ? ",@(1),@(fileChunkInfo.fileID)];
        
        if (isSuccess && success) {
            block([[ProtocolDataManager sharedProtocolDataManager] resUpFileDataWithRet:ResponsTypeUpSuccess andFileID:fileChunkInfo.fileID],ResponsTypeUpSuccess);
        }else{
            block([[ProtocolDataManager sharedProtocolDataManager] resUpFileDataWithRet:ResponsTypeServerError andFileID:0],ResponsTypeServerError);
        }

    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resUpFileDataWithRet:ResponsTypeUping andFileID:fileChunkInfo.fileID],ResponsTypeUping);
    }

}

//查询文件是否存在
- (void)queryFileWith:(ReqDownFileInfo *)reqDownInfo withResultBlock:(ResultBlock)block
{
    //未登录
    NSNumber *token = [NSNumber numberWithUnsignedShort:reqDownInfo.userToken];
    if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        block([[ProtocolDataManager sharedProtocolDataManager] resReqDownFileDataWithRet:ResponsTypeNoLogin andFileID:0],ResponsTypeNoLogin);
        return;
    }

    FMResultSet *res = [_db executeQuery:@"SELECT file_id FROM file WHERE file_name = ? AND directory_id = ? AND file_state = ?",reqDownInfo.fileName,@(reqDownInfo.directoryID),@(1)];
    NSLog(@"%@",@(reqDownInfo.directoryID));
    NSLog(@"%@",reqDownInfo.fileName);
    BOOL isExistFile = NO;
    u_short fileID = 0;
    while ([res next]) {
        fileID = (u_short)[res intForColumn:@"file_id"];
        isExistFile = YES;
    }
    if (!isExistFile) {
        block([[ProtocolDataManager sharedProtocolDataManager] resReqDownFileDataWithRet:ResponsTypeReqDownNull andFileID:0],ResponsTypeReqDownNull);
    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resReqDownFileDataWithRet:ResponsTypeReqDownSuccess andFileID:fileID],ResponsTypeReqDownSuccess);
    }
    
}

//文件下载
- (void)getFileDataWith:(DownFileInfo *)downFileInfo withResultBlock:(void(^)(NSArray *replyDatas,ResponsType resType))block
{
    //未登录
    NSNumber *token = [NSNumber numberWithUnsignedShort:downFileInfo.userToken];
    if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        block(@[[[ProtocolDataManager sharedProtocolDataManager] resDownFileDataWithRet:ResponsTypeNoLogin andFileID:0 andChunks:0 andCurrentChunk:0 andDataSize:0 andSubFileData:0]],ResponsTypeNoLogin);
        return;
    }
    
    FMResultSet *res = [_db executeQuery:@"SELECT file_name FROM file WHERE file_id = ? AND file_state = ?",@(downFileInfo.fileID),@(1)];
    
    BOOL isExistFile = NO;
    NSString *fileName;
    while ([res next]) {
        fileName = [res stringForColumn:@"file_name"];
        isExistFile = YES;
    }
    
    if (!isExistFile) {
       block(@[[[ProtocolDataManager sharedProtocolDataManager] resDownFileDataWithRet:ResponsTypeDownNUll andFileID:0 andChunks:0 andCurrentChunk:0 andDataSize:0 andSubFileData:0]],ResponsTypeNoLogin);
    }else{
        NSString *path = [MainLib stringByAppendingPathComponent:fileName];
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        NSMutableArray *dataArray = [NSMutableArray array];
        u_short chunks = fileData.length / 1024 + 1;
        NSLog(@"%lu",(unsigned long)fileData.length);
        NSLog(@"%hu",chunks);
        for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
            
            NSData *data;
            if (currentChunk == chunks) {
                u_short size = fileData.length % 1024;
                NSLog(@"%hu",size);
                NSLog(@"%hu",currentChunk);
                NSData *subData = [fileData subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
                data = [[ProtocolDataManager sharedProtocolDataManager] resDownFileDataWithRet:ResponsTypeDownSuccess andFileID:downFileInfo.fileID andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData];
            }else{
                NSData *subData = [fileData subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
                data = [[ProtocolDataManager sharedProtocolDataManager] resDownFileDataWithRet:ResponsTypeDownIng andFileID:downFileInfo.fileID andChunks:chunks andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData];
                
            }
            [dataArray addObject:data];
        }
        
        block(dataArray,ResponsTypeDownSuccess);
    
    }
}

//创建一个文件夹
- (void)addFolderWith:(CreatFolderInfo *)folderInfo withResultBlock:(ResultBlock)block
{
    
    if (folderInfo.diretoryName.length < 1) {
        block([[ProtocolDataManager sharedProtocolDataManager] resCreatDiretoryWithRet:ResponsTypeFolderNameNull],ResponsTypeFolderNameNull);
       return;
    }
    //未登录
    NSNumber *token = [NSNumber numberWithUnsignedShort:folderInfo.userToken];
    if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        block([[ProtocolDataManager sharedProtocolDataManager] resCreatDiretoryWithRet:ResponsTypeNoLogin],ResponsTypeNoLogin);
        return;
    }

    FMResultSet *res = [_db executeQuery:@"SELECT * FROM directory WHERE directory_id = ?",@(folderInfo.diretoryID)];
    FMResultSet *res2 = [_db executeQuery:@"SELECT * FROM directory WHERE parent_id = ?",@(folderInfo.diretoryID)];
    
    BOOL isExist = NO;
    BOOL haveFolder = NO;
    
    while ([res next]) {
        isExist = YES;
    }
    
    
    while ([res2 next]) {
        if ([folderInfo.diretoryName isEqualToString:[res2 stringForColumn:@"directory_name"]]) {
            haveFolder = YES;
        }
    }
    
    //未找到父ID
    if (!isExist) {
        block([[ProtocolDataManager sharedProtocolDataManager] resCreatDiretoryWithRet:ResponsTypeFolderParentNoExist],ResponsTypeFolderParentNoExist);
        return;
    }
    
    //父ID下存在该文件夹
    if (haveFolder) {
        block([[ProtocolDataManager sharedProtocolDataManager] resCreatDiretoryWithRet:ResponsTypeFolderExist],ResponsTypeFolderExist);
        return;
    }

    BOOL isSucceed = [_db executeUpdate:@"INSERT INTO directory(directory_name,parent_id)VALUES(?,?)",folderInfo.diretoryName,@(folderInfo.diretoryID)];
    
    if (isSucceed) {
        block([[ProtocolDataManager sharedProtocolDataManager] resCreatDiretoryWithRet:ResponsTypeAddFolderSuccess],ResponsTypeAddFolderSuccess);
    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resCreatDiretoryWithRet:ResponsTypeServerError],ResponsTypeServerError);
    }

}

//删除一个文件夹
- (void)moveFolderWith:(MoveFolderInfo *)folderInfo withResultBlock:(ResultBlock)block
{

    //未登录
    NSNumber *token = [NSNumber numberWithUnsignedShort:folderInfo.userToken];
    if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        block([[ProtocolDataManager sharedProtocolDataManager] resMoveDiretoryWithRet:ResponsTypeNoLogin],ResponsTypeNoLogin);
        return;
    }
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM directory WHERE directory_id = ? AND parent_id = ?",@(folderInfo.diretoryID),@(folderInfo.parentID)];

    
    BOOL isExist = NO;
    
    while ([res next]) {
        isExist = YES;
    }

    //未找到父ID或者文件夹不存在
    if (!isExist) {
        block([[ProtocolDataManager sharedProtocolDataManager] resMoveDiretoryWithRet:ResponsTypeNoFolderOrNoParent],ResponsTypeNoFolderOrNoParent);
        return;
    }
    
    BOOL isSucceed = [_db executeUpdate:@"DELETE FROM directory WHERE directory_id = ?",@(folderInfo.diretoryID)];
    
    if (isSucceed) {
        block([[ProtocolDataManager sharedProtocolDataManager] resMoveDiretoryWithRet:ResponsTypeMoveFolderSuccess],ResponsTypeMoveFolderSuccess);
    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resMoveDiretoryWithRet:ResponsTypeServerError],ResponsTypeServerError);
    }

}

//获取文件列表
- (void)getFileListWith:(FileListInfo *)fileListInfo withResultBlock:(ResultBlock)block
{
    //未登录
    NSNumber *token = [NSNumber numberWithUnsignedShort:fileListInfo.userToken];
    if (![[AppDataSource shareAppDataSource].currentUsers containsObject:token]) {
        block([[ProtocolDataManager sharedProtocolDataManager] resFileListWithRet:ResponsTypeNoLogin andParentID:fileListInfo.directoryID andSourceModels:[NSArray array]],ResponsTypeNoLogin);
        return;
    }
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM directory WHERE parent_id = ?",@(fileListInfo.directoryID)];
    FMResultSet *res2 = [_db executeQuery:@"SELECT * FROM file WHERE directory_id = ? AND file_state = 1",@(fileListInfo.directoryID)];
    
    NSMutableArray *listModels = [NSMutableArray array];
    while ([res next]) {
        SourceModel *source = [SourceModel new];
        source.type = 0;
        source.sourceID = (u_short)[res intForColumn:@"directory_id"];
        source.sourceName = [res stringForColumn:@"directory_name"];
        [listModels addObject:source];
    }
    
    while ([res2 next]) {
        SourceModel *source = [SourceModel new];
        source.type = 1;
        source.sourceID = (u_short)[res2 intForColumn:@"file_id"];
        source.sourceName = [res2 stringForColumn:@"file_name"];
        [listModels addObject:source];
    }

    
    if (listModels.count > 0) {
        block([[ProtocolDataManager sharedProtocolDataManager] resFileListWithRet:ResponsTypeFileListSuccess andParentID:fileListInfo.directoryID andSourceModels:listModels],ResponsTypeFileListSuccess);
    }else{
        block([[ProtocolDataManager sharedProtocolDataManager] resFileListWithRet:ResponsTypeFileListNoFolder andParentID:fileListInfo.directoryID andSourceModels:[NSArray array]],ResponsTypeFileListNoFolder);
    
    }
}



@end
