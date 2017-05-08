//
//  socketClientManager.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/3.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "socketClientManager.h"
#import "GCDAsyncSocket.h"
#import "AppDataSource.h"
#import "HeaderInfo.h"
#import "ProtocolDataManager.h"
#import "ClientSocketBufferAndTag.h"

static socketClientManager *_clientManager;

@interface socketClientManager()<GCDAsyncSocketDelegate>

@property (nonatomic , strong)GCDAsyncSocket *socketClient;
@property (nonatomic , strong)NSMutableData *readBuff;


@end


@implementation socketClientManager

+(instancetype)sharedClientManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _clientManager = [[self alloc]init];
       
    });
    return _clientManager;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.socketClient = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.readBuff = [NSMutableData data];
    }
    return self;
}

#pragma mark 连接和断开

- (BOOL)connectServer
{
    NSError *error;
    [self.socketClient disconnect];
    // 连接服务器
    [self.socketClient connectToHost:[[AppDataSource shareAppDataSource] deviceIPAdress] onPort:6666 error:&error];
    
    if (error) {
        return NO;
    }else{
        return YES;
    }

}

- (BOOL)disconnectServer
{
    [self.socketClient disconnect];
    
    return [self.socketClient isDisconnected];
}

#pragma mark GCDAsyncSocketDelegate
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        NSLog(@"连接失败");
    }else{
        NSLog(@"正常断开");
    }
    
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:tag];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{

    [self.readBuff appendData:data];
    
//    NSLog(@"客户端当前sock  ----- %@",sock);
//    NSLog(@"客户端当前线程 :--%@",[NSThread currentThread]);
//    NSLog(@"客户端二进制流数据长度: -- %ld" , (unsigned long)data.length);
//    NSLog(@"客户端readBuff数据长度: -- %ld" , (unsigned long)self.readBuff.length);
    
    while (_readBuff.length >= 8) {
        
        @try {
            HeaderInfo *header = [[ProtocolDataManager sharedProtocolDataManager] getRespondHeaderInfoWithData:[self.readBuff subdataWithRange:NSMakeRange(0, 8)]];
            NSInteger complateDataLength = header.c_length + 8;
            
            if (_readBuff.length >= complateDataLength) {
                
                NSData *subData = [_readBuff subdataWithRange:NSMakeRange(0, complateDataLength)];
                [self handleTcpResponseData:subData andSocket:sock];
                _readBuff = [NSMutableData dataWithData:[_readBuff subdataWithRange:NSMakeRange(complateDataLength, _readBuff.length - complateDataLength)]];
            } else {
                [sock readDataWithTimeout:-1 tag:0];
                return;
            }
        } @catch (NSException *exception) {
            
            self.readBuff = nil;
            self.readBuff = [NSMutableData data];
            [sock disconnect];

        }
        
        
    }
    [sock readDataWithTimeout:-1 tag:0];
    
}

#pragma mark 数据包解析后回调
//发送登录请求
- (void)sendLoginInfo:(UserInfo *)userInfo
{
    
    NSData *data = [[ProtocolDataManager sharedProtocolDataManager] loginDataWithUserName:userInfo.userName andPassword:userInfo.userPwd];
    [self.socketClient writeData:data withTimeout:-1 tag:0];
    
}

//请求上传文件
- (void)sendReqFileupWithName:(NSString *)fileName andDirectoryID:(u_short)directoryID andSize:(uint)size
{

    NSLog(@"客户端当前线程 :--%@",[NSThread currentThread]);
    NSData *data = [[ProtocolDataManager sharedProtocolDataManager] reqUpFileDataWithFileName:fileName andDirectoryID:directoryID andSize:size];
    [self.socketClient writeData:data withTimeout:-1 tag:0];

}

//上传文件
- (void)sendFileDataWithUserToken:(u_short)userToken andFileID:(u_short)fileID andChunks:(u_short)chunks andCurrentChunk:(u_short)chunk andDataSize:(u_short)size andSubFileData:(NSData *)subData
{

    NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:userToken andFileID:fileID andChunks:chunks andCurrentChunk:chunk andDataSize:size andSubFileData:subData];
    [self.socketClient writeData:data withTimeout:-1 tag:0];

}


#pragma mark  数据包解析

- (void)handleTcpResponseData:(NSData *)data andSocket:(GCDAsyncSocket *)sock
{

    HeaderInfo *header = [[ProtocolDataManager sharedProtocolDataManager] getRespondHeaderInfoWithData:[data subdataWithRange:NSMakeRange(0, 8)]];
    
    switch (header.cmd) {
        case CmdTypeReigter:{
            @try {
                
                
            } @catch (NSException *exception) {

            }
            
            
        }
            break;
        case CmdTypeLogin:{
            
            @try {
                Byte resultType;
                u_short key;
                [[data subdataWithRange:NSMakeRange(8, 1)] getBytes:&resultType length:sizeof(Byte)];
                [[data subdataWithRange:NSMakeRange(10, 2)] getBytes:&key length:sizeof(u_short)];

                [self.delegate receiveReplyType:resultType andKey:key andCmd:CmdTypeLogin];

            } @catch (NSException *exception) {

            }
            
            
        }
            break;
        case CmdTypeReqUp:{
            
            @try {
                Byte resultType;
                u_short key;
                [[data subdataWithRange:NSMakeRange(8, 1)] getBytes:&resultType length:sizeof(Byte)];
                [[data subdataWithRange:NSMakeRange(10, 2)] getBytes:&key length:sizeof(u_short)];
                [self.delegate receiveReplyType:resultType andKey:key andCmd:CmdTypeReqUp];
            } @catch (NSException *exception) {
     
            }
            
        }
            break;
        case CmdTypeUp:{
            
            @try {
                
                Byte resultType;
                u_short key;
                [[data subdataWithRange:NSMakeRange(8, 1)] getBytes:&resultType length:sizeof(Byte)];
                [[data subdataWithRange:NSMakeRange(10, 2)] getBytes:&key length:sizeof(u_short)];
                [self.delegate receiveReplyType:resultType andKey:key andCmd:CmdTypeUp ];
            } @catch (NSException *exception) {

            }
            
        }
            break;
        case CmdTypeReqDown:{
            
            @try {

 
      
            } @catch (NSException *exception) {

            }
            
        }
            break;
        case CmdTypeDown:{
            
            @try {


                
            } @catch (NSException *exception) {

            }
        }
            break;
        case CmdTypeAddFolder:{
            
            @try {

            } @catch (NSException *exception) {

            }
            
            
        }
            break;
        case CmdTypeRemoveFolder:{
            
            @try {

                
            } @catch (NSException *exception) {

            }
        }
            break;
        case CmdTypeGetList:{
            
            @try {

                
            } @catch (NSException *exception) {

            }
            
        }
            break;
            
        default:
            break;
    }
    
    
}




@end
