//
//  ClientViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/20.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ClientViewController.h"
#import "GCDAsyncSocket.h"
#import "AppDataSource.h"
#import "NSObject+YYModel.h"
#import "UserInfo.h"
#import "DataBaseManager.h"
#import "ProtocolDataManager.h"

@interface ClientViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic , strong)GCDAsyncSocket *socketClient;


@end

@implementation ClientViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"客户端";
    
    NSArray *titileArray = @[@"请求连接" ,@"注册",@"登录",@"请求上传文件",@"上传大文件"];
    self.view.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < titileArray.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.bounds = CGRectMake(0, 0, 300, 30);
        button.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, 60 + i *45);
        [button setTitle:titileArray[i] forState:UIControlStateNormal];
        button.tag =  10+i;
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
}

#pragma mark - 事件监听

- (void)buttonPressed:(UIButton *)sender {
    switch (sender.tag - 10) {
        case 0: {
            uint16_t prot = 6666;
            // 创建服务器
            self.socketClient = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("clientQueue", DISPATCH_QUEUE_SERIAL)];

            NSError *error;
            // 连接服务器
            [self.socketClient connectToHost:@"10.134.19.1" onPort:prot error:&error];
        
            if (error) {
                NSLog(@"连接失败 ： %@",error);
            }else{
                
                NSLog(@"连接成功");
            }

        
        }
            
            break;
            
        case 1:{
            
            
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] regDataWithUserName:@"聂自强" andPassword:@"222222"];
            [self.socketClient writeData:data withTimeout:-1 tag:0];
        
        }
            break;
        case 2:{
            
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] loginDataWithUserName:@"聂自强" andPassword:@"222222"];
            [self.socketClient writeData:data withTimeout:-1 tag:0];

            
        }
            break;
        case 3:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"NZQ" ofType:@"mp4"];
            NSError *error;
            NSData *filedata = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] reqUpFileDataWithFileName:@"NZQ.mp4" andDirectoryID:1 andSize:(u_int)filedata.length];
            [self.socketClient writeData:data withTimeout:-1 tag:0];
            
            sleep(1);
            
            NSData *data2 = [[ProtocolDataManager sharedProtocolDataManager] reqUpFileDataWithFileName:@"aaaa.mp4" andDirectoryID:1 andSize:(u_int)filedata.length];
            [self.socketClient writeData:data2 withTimeout:-1 tag:0];
            
        }
            break;
        case 4:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"BBB" ofType:@"jpg"];
//            NSData *filedata = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            NSData *filedata = [NSData dataWithContentsOfFile:path];
            
            u_short chunks = filedata.length / 1024 + 1;
//            u_short size = filedata.length % 1024;
            NSLog(@"%lu",(unsigned long)filedata.length);
            NSLog(@"%hu",chunks);
//            NSLog(@"%hu",size);
            
            dispatch_async(dispatch_queue_create("sendFile", DISPATCH_QUEUE_SERIAL), ^{
                for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
                    
                    if (currentChunk == chunks) {
                        u_short size = filedata.length % 1024;
                        NSLog(@"%hu",size);
                        NSLog(@"%hu",currentChunk);
                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:1 andFileID:1 andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData];
                        
                        
                        [self.socketClient writeData:data withTimeout:-1 tag:0];
                        sleep(1);
                        
                    }else{
                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:1 andFileID:1 andChunks:chunks andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData];
                        
                        [self.socketClient writeData:data withTimeout:-1 tag:0];
                        
                        sleep(1);
                        
                    }
                    
                }
            });
            
//            dispatch_async(dispatch_queue_create("sendFisdsdle", DISPATCH_QUEUE_SERIAL), ^{
//                for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
//                    
//                    if (currentChunk == chunks) {
//                        u_short size = filedata.length % 1024;
//                        NSLog(@"%hu",size);
//                        NSLog(@"%hu",currentChunk);
//                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
//                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:1 andFileID:2 andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData];
//                        
//                        
//                        [self.socketClient writeData:data withTimeout:-1 tag:0];
//                        sleep(1);
//                        
//                    }else{
//                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
//                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:1 andFileID:2 andChunks:chunks andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData];
//                        
//                        [self.socketClient writeData:data withTimeout:-1 tag:0];
//                        
//                        sleep(1);
//                        
//                    }
//                    
//                }
//            });
 
        }
            break;
            
        default:
            break;
    }
    
    
}


#pragma mark -socket的代理

#pragma mark 连接成功

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    //连接成功
    NSLog(@"%s",__func__);
}

#pragma mark 断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        NSLog(@"连接失败");
    }else{
        NSLog(@"正常断开");
    }
}

#pragma mark 数据发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    NSLog(@"%s",__func__);
//    
    [sock readDataWithTimeout:-1 tag:tag];
}

#pragma mark 读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"当前sock  ----- %@",sock);
    NSLog(@"二进制流数据: -- %ld" , data.length);
    
    Byte ret;
    [[data subdataWithRange:NSMakeRange(8, 1)] getBytes:&ret length:sizeof(Byte)];
    
    NSLog(@"%d",ret);
}

@end
