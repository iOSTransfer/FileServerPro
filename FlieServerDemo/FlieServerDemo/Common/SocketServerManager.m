//
//  SocketServerManager.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/3.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "SocketServerManager.h"
#import "GCDAsyncSocket.h"
#import "AppDataSource.h"
#import "ProtocolDataManager.h"
#import "DataBaseManager.h"
#import "EnumList.h"


#define MainLib [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Main"]
#define TmpLib [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Tmp"]



static SocketServerManager *_serverManager;

@interface SocketServerManager()<GCDAsyncSocketDelegate>


@property (nonatomic ,strong)GCDAsyncSocket *serverSocket;
@property (strong, nonatomic)NSMutableSet *clientSockets;//保存客户端scoket

@end


@implementation SocketServerManager


+ (instancetype)sharedServerManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _serverManager = [[self alloc]init];
        //创建一个主目录(没有就创建)
        if (![[NSFileManager defaultManager] fileExistsAtPath:MainLib isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:MainLib
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:TmpLib isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:TmpLib
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
    });
    return _serverManager;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }

    return self;
}

- (NSMutableSet *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [[NSMutableSet alloc]init];
        
    }
    return _clientSockets;
}

#pragma mark 开启服务和关闭服务

- (BOOL)openServer
{
    NSError *error = nil;
    [self.serverSocket acceptOnPort:6666 error:&error];
    
    if (error) {
        return false;
    }else{
        return true;
    }

}

- (BOOL)closeServer
{
    [self.serverSocket disconnect];
    
    return [self.serverSocket isDisconnected];

}

#pragma mark GCDAsyncSocketDelegate

//连接到客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{

    [self.clientSockets addObject:newSocket];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFIER_STRING object:@(self.clientSockets.count)];
    NSLog(@"服务端当前链接sockets:%@",self.clientSockets);
    [newSocket readDataWithTimeout:-1 tag:0];
}

//接收到客户端数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
//    NSLog(@"当前sock  ----- %@",sock);
//    NSLog(@"当前线程 :--%@",[NSThread currentThread]);
    NSLog(@"二进制流数据长度: -- %ld" , data.length);
    
    
    //接受到用户数据，开始解析
    HeaderInfo *header;
    @try {
        header = [[ProtocolDataManager sharedProtocolDataManager] getHeaderInfoWithData:[data subdataWithRange:NSMakeRange(0, 8)]];
    } @catch (NSException *exception) {
        [sock disconnect];
        [self.clientSockets removeObject:sock];
        
    }
    
    switch (header.cmd) {
        case CmdTypeReigter:{
            @try {
                
                UserInfo *user = [[ProtocolDataManager sharedProtocolDataManager] getUserInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                
                [[DataBaseManager sharedDataBase] addUserInfoWithName:user.userName andPwd:user.userPwd withResultBlock:^(NSData *replyData, ResponsType resType) {
                    //返回响应数据流
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeReigter andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];
                
            } @catch (NSException *exception) {
                //返回响应异常数据流
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeReigter andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
            
            
        }
            break;
        case CmdTypeLogin:{
            
            @try {
                UserInfo *user = [[ProtocolDataManager sharedProtocolDataManager] getUserInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                
                [[DataBaseManager sharedDataBase] userLoginWithName:user.userName andPwd:user.userPwd withResultBlock:^(NSData *replyData, ResponsType resType) {
                    //返回响应数据流
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeLogin andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];
                
                
            } @catch (NSException *exception) {
                //返回响应异常数据流
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeLogin andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
            
            
        }
            break;
        case CmdTypeReqUp:{
            
            @try {
                ReqUpFileInfo *reqInfo = [[ProtocolDataManager sharedProtocolDataManager] getReqFileInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                
                [[DataBaseManager sharedDataBase] addFileInfoWithName:reqInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                    //返回响应数据流
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeReqUp andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];
                
                
                
            } @catch (NSException *exception) {
                //返回响应异常数据流
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeReqUp andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
            
        }
            break;
        case CmdTypeUp:{
            
            @try {
                
                NSArray *chunkInfos = [self getFileChunkInfosWithData:data];
                for (FileChunkInfo * chunkInfo in chunkInfos) {
//                    NSLog(@"\n 当前的chunk： %hu \n 当前线程：%@ \n 当前sock:%@  \n当前fileID:%hu",chunkInfo.chunk,[NSThread currentThread],sock,chunkInfo.fileID);
                    [[DataBaseManager sharedDataBase] cachesSubFileDataWith:chunkInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                        //返回响应数据流
                        [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeUp andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                    }];
  
                }
                
                //更新内存
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFIER_STRING object:nil];
                
            } @catch (NSException *exception) {
                //返回响应异常数据流
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeUp andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
            
        }
            break;
        case CmdTypeReqDown:{
            
            @try {
                ReqDownFileInfo *reqInfo = [[ProtocolDataManager sharedProtocolDataManager] getReqDownFileInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                
                [[DataBaseManager sharedDataBase] queryFileWith:reqInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                    //返回响应数据流
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeReqDown andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];
            } @catch (NSException *exception) {
                //返回响应异常数据流
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeReqDown andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
            
        }
            break;
        case CmdTypeDown:{
            
            @try {
                DownFileInfo *downInfo = [[ProtocolDataManager sharedProtocolDataManager] getDownFileInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                [[DataBaseManager sharedDataBase]getFileDataWith:downInfo withResultBlock:^(NSArray *replyDatas, ResponsType resType) {
                    
                    for (NSData *subData in replyDatas) {
                        [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeDown andResult:ResultTypeSuccess andData:subData]  withTimeout:-1 tag:0];
                    }
                    
                }];
                
            } @catch (NSException *exception) {
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeDown andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
        }
            break;
        case CmdTypeAddFolder:{
            
            @try {
                CreatFolderInfo *creatInfo = [[ProtocolDataManager sharedProtocolDataManager] getCreatFolderInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                [[DataBaseManager sharedDataBase] addFolderWith:creatInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeAddFolder andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];
                
            } @catch (NSException *exception) {
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeAddFolder andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
            
            
        }
            break;
        case CmdTypeRemoveFolder:{
            
            @try {
                MoveFolderInfo *moveInfo = [[ProtocolDataManager sharedProtocolDataManager] getMoveFolderInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                [[DataBaseManager sharedDataBase] moveFolderWith:moveInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeRemoveFolder andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];
                
            } @catch (NSException *exception) {
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeRemoveFolder andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
        }
            break;
        case CmdTypeGetList:{
            
            @try {
                FileListInfo *listInfo = [[ProtocolDataManager sharedProtocolDataManager] getFileListInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                [[DataBaseManager sharedDataBase] getFileListWith:listInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeGetList andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];
                
            } @catch (NSException *exception) {
                [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeGetList andResult:ResultTypeDataError andData:[NSData new]]  withTimeout:-1 tag:0];
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:tag];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    NSLog(@"%@断开 ，错误：%@",sock,err);
    
    if ([self.clientSockets containsObject:sock]) {
        [self.clientSockets removeObject:sock];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFIER_STRING object:@(self.clientSockets.count)];
}

#pragma mark  分包解析
//分包
- (NSArray *)getFileChunkInfosWithData:(NSData *)subData
{
    NSMutableArray *muArray = [NSMutableArray array];
    
    while (subData.length) {
        
        HeaderInfo *header = [[ProtocolDataManager sharedProtocolDataManager] getHeaderInfoWithData:[subData subdataWithRange:NSMakeRange(0, 8)]];
        if (header.c_length <= subData.length) {
            
            FileChunkInfo *info = [[ProtocolDataManager sharedProtocolDataManager]getFileChunkInfoWithData:[subData subdataWithRange:NSMakeRange(8, header.c_length)]];
            [muArray addObject:info];
            subData = [subData subdataWithRange:NSMakeRange(8 +  header.c_length, subData.length - 8 -  header.c_length )];
        }else{
            NSLog(@"包不完整");
        }
        
        
        
        
    }
    
    return muArray;
}


@end
