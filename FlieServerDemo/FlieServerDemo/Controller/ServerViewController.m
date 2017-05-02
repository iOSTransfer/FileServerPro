//
//  ServerViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/21.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ServerViewController.h"
#import "GCDAsyncSocket.h"
#import "StartView.h"
#import "AppDataSource.h"
#import "NSObject+YYModel.h"
#import "UserInfo.h"
#import "ProtocolDataManager.h"
#import "DataBaseManager.h"
#import "EnumList.h"



#define MainLib [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Main"]
#define TmpLib [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Tmp"]

@interface ServerViewController ()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableSet *clientSockets;//保存客户端scoket
@property (strong, nonatomic) NSMutableData *receiveData;
@property (strong, nonatomic) StartView *startServer;
@property (strong ,nonatomic) NSMutableArray *dataArray;

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1];
    self.navigationItem.title = @"服务器";
    
    [self setUI];
}

- (void)setUI
{
    
    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 24)];
    
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    NSString *infoString = [NSString stringWithFormat:@"IP地址:%@ 端口号:6666",[[AppDataSource shareAppDataSource] deviceIPAdress]];
    infoLabel.text = infoString;
    [self.view addSubview:infoLabel];
    
    
    self.startServer = [[StartView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.startServer.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    [self.startServer setTitle:@"Start"];
    __weak typeof (ServerViewController *)weakSelf = self;
    [self.startServer addAction:^{
        [weakSelf openServer];
    }];
    [self.view addSubview:self.startServer];
    

}


#pragma mark -懒加载
- (NSMutableSet *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [[NSMutableSet alloc]init];
    }
    return _clientSockets;
}

- (NSMutableData *)receiveData
{
    if (!_receiveData) {
        _receiveData = [[NSMutableData alloc]init];
    }
    return _receiveData;
  
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}


#pragma mark - 事件监听

- (void)openServer
{
    
    if (self.socket != nil) {
        [self.startServer stop];
        [self.startServer setTitle:@"Start"];
        self.socket = nil;
        return;
    }
    
    //1.创建scoket对象
    GCDAsyncSocket *serviceScoket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    //2.绑定端口(6666)
    NSError *error = nil;
    [serviceScoket acceptOnPort:6666 error:&error];
    
    //3.开启服务(实质第二步绑定端口的同时默认开启服务)
    if (error == nil) {
        [self.startServer start];
        [self.startServer setTitle:@"Success"];
        
        NSLog(@"开启成功");
    } else {
        
        NSLog(@"开启失败");
    }
    self.socket = serviceScoket;
    
    //创建一个主目录
    if (![[NSFileManager defaultManager] fileExistsAtPath:MainLib isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:MainLib
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }

    
    if (![[NSFileManager defaultManager] fileExistsAtPath:TmpLib isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:TmpLib
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    

}


#pragma mark GCDAsyncSocketDelegate





//连接到客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //sock 服务端的socket
    //newSocket 客户端连接的socket
    NSLog(@"%@----%@",sock, newSocket);
    
    //1.保存连接的客户端socket(否则newSocket释放掉后链接会自动断开)
    [self.clientSockets addObject:newSocket];
    NSLog(@"%@",self.clientSockets);
    
    //2.监听客户端有没有数据上传
    [newSocket readDataWithTimeout:-1 tag:0];
}

//接收到客户端数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"当前sock  ----- %@",sock);
    NSLog(@"当前线程 :--%@",[NSThread currentThread]);
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
                FileChunkInfo *chunkInfo = [[ProtocolDataManager sharedProtocolDataManager] getFileChunkInfoWithData:[data subdataWithRange:NSMakeRange(8, header.c_length)]];
                
                
                NSLog(@"\n 当前的chunk： %hu \n 当前线程：%@ \n 当前sock:%@  \n当前fileID:%hu",chunkInfo.chunk,[NSThread currentThread],sock,chunkInfo.fileID);
                
                
                [[DataBaseManager sharedDataBase] cachesSubFileDataWith:chunkInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                    //返回响应数据流
                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeUp andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                }];

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
                [[DataBaseManager sharedDataBase]getFileDataWith:downInfo withResultBlock:^(NSData *replyData, ResponsType resType) {
                    
                    if (resType == ResponsTypeDownIng) {
                        
                        u_short chunks = replyData.length / 1024 + 1;
                        NSLog(@"%lu",(unsigned long)replyData.length);
                        NSLog(@"%hu",chunks);
//                        dispatch_async(dispatch_queue_create("sendFile", DISPATCH_QUEUE_SERIAL), ^{
                        
                            for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
                                
                                if (currentChunk == chunks) {
                                    u_short size = replyData.length % 1024;
                                    NSLog(@"%hu",size);
                                    NSLog(@"%hu",currentChunk);
                                    NSData *subData = [replyData subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
                                    
                                    //返回响应数据流
                                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeDown andResult:ResultTypeSuccess andData:[[ProtocolDataManager sharedProtocolDataManager] resDownFileDataWithRet:ResponsTypeDownSuccess andFileID:1 andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData]]  withTimeout:-1 tag:0];
                                    
//                                    [NSThread sleepForTimeInterval:1.0];
                                    [sock readDataWithTimeout:-1 tag:0];
                                }else{
                                    NSData *subData = [replyData subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
                                    //返回响应数据流
                                    [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeDown andResult:ResultTypeSuccess andData:[[ProtocolDataManager sharedProtocolDataManager] resDownFileDataWithRet:ResponsTypeDownIng andFileID:1 andChunks:chunks andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData]]  withTimeout:-1 tag:0];
                                    [sock readDataWithTimeout:-1 tag:0];
//                                    [NSThread sleepForTimeInterval:1.0];
                                }
                                
                            }
                            
//                        });
                        
                    }else{
                        //返回响应数据流
                        [sock writeData:[[ProtocolDataManager sharedProtocolDataManager] resHeaderDataWithCmd:CmdTypeDown andResult:ResultTypeSuccess andData:replyData]  withTimeout:-1 tag:0];
                    
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
   
    
    
    //不需要断开.
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    NSLog(@"%@断开 ，错误：%@",sock,err);

    [self.clientSockets removeObject:sock];
}



//设置StatusBar的样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
