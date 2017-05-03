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

static socketClientManager *_clientManager;

@interface socketClientManager()<GCDAsyncSocketDelegate>

@property (nonatomic , strong)GCDAsyncSocket *socketClient;

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
    }
    return self;
}

#pragma mark 连接和断开

- (BOOL)connectServer
{
    NSError *error;
    
    // 连接服务器
    [self.socketClient connectToHost:[[AppDataSource shareAppDataSource] deviceIPAdress] onPort:6666 error:&error];
    
    if (error) {
        return false;
    }else{
        return true;
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
    [self connectServer];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:tag];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    Byte ret;
    [[data subdataWithRange:NSMakeRange(8, 1)] getBytes:&ret length:sizeof(Byte)];
    
    NSLog(@"客户端接收命令: --%d",ret);
    NSLog(@"客户端数据长度: -- %ld" , data.length);
}




@end
