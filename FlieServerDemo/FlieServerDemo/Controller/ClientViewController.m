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
    
    NSArray *titileArray = @[@"请求连接" ,@"注册",@"登录",@"请求上传文件",@"上传大文件",@"创建文件夹",@"删除文件夹",@"请求下载",@"下载文件",@"获取文件列表"];
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
            self.socketClient = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_SERIAL)];

            NSError *error;
            
            // 连接服务器
            [self.socketClient connectToHost:[[AppDataSource shareAppDataSource] deviceIPAdress] onPort:prot error:&error];
        
            if (error) {
                NSLog(@"连接失败 ： %@",error);
            }else{
                
                NSLog(@"连接成功");
            }

        
        }
            
            break;
            
        case 1:{
            
            
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] regDataWithUserName:@"aaaa" andPassword:@"111111"];
            [self.socketClient writeData:data withTimeout:-1 tag:0];
        
        }
            break;
        case 2:{
            
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] loginDataWithUserName:@"oo" andPassword:@"123"];
            [self.socketClient writeData:data withTimeout:-1 tag:0];

            
        }
            break;
        case 3:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"BBB" ofType:@"jpg"];
            NSError *error;
            NSData *filedata = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] reqUpFileDataWithFileName:@"kkkkkkkk.jpg" andDirectoryID:1 andSize:(u_int)filedata.length];
            [self.socketClient writeData:data withTimeout:-1 tag:0];
            
//            sleep(1);
//            
//            NSData *data2 = [[ProtocolDataManager sharedProtocolDataManager] reqUpFileDataWithFileName:@"ooooooooo.mp4" andDirectoryID:1 andSize:(u_int)filedata.length];
//            [self.socketClient writeData:data2 withTimeout:-1 tag:0];
            
        }
            break;
        case 4:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"BBB" ofType:@"jpg"];
            NSData *filedata = [NSData dataWithContentsOfFile:path];
            
            u_short chunks = filedata.length / 1024 + 1;
//            u_short size = filedata.length % 1024;
//            NSLog(@"%lu",(unsigned long)filedata.length);
//            NSLog(@"%hu",chunks);
//            NSLog(@"%hu",size);
            
            dispatch_async(dispatch_queue_create("sendFile", DISPATCH_QUEUE_SERIAL), ^{
                for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
                    
                    if (currentChunk == chunks) {
                        u_short size = filedata.length % 1024;
                        NSLog(@"%hu",size);
//                        NSLog(@"%hu",currentChunk);
                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:2 andFileID:49 andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData];
                        
                        
                        [self.socketClient writeData:data withTimeout:-1 tag:0];
                        
                        
                    }else{
                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:2 andFileID:49 andChunks:chunks andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData];
                        
                        
                        [self.socketClient writeData:data withTimeout:-1 tag:0];
                        
                        
                    }
                    
                }
            });
            
//            NSString *path1 = [[NSBundle mainBundle] pathForResource:@"NZQ" ofType:@"mp4"];
//            NSData *filedata1 = [NSData dataWithContentsOfFile:path1];
//            
//            u_short chunks1 = filedata1.length / 1024 + 1;
//            
//            dispatch_async(dispatch_queue_create("sendFisdsdle", DISPATCH_QUEUE_SERIAL), ^{
//                for (u_short currentChunk = 1; currentChunk <= chunks1; currentChunk++) {
//                    
//                    if (currentChunk == chunks1) {
//                        u_short size = filedata1.length % 1024;
////                        NSLog(@"%hu",size);
////                        NSLog(@"%hu",currentChunk);
//                        NSData *subData = [filedata1 subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
//                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:1 andFileID:50 andChunks:chunks1 andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData];
//                        
//                        
//                        [self.socketClient writeData:data withTimeout:-1 tag:0];
//
//                        
//                    }else{
//                        NSData *subData = [filedata1 subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
//                        NSData *data = [[ProtocolDataManager sharedProtocolDataManager] upFileDataWithUserToken:1 andFileID:50 andChunks:chunks1 andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData];
//                        
//                        [self.socketClient writeData:data withTimeout:-1 tag:0];
//
//                        
//                    }
//                    
//                }
//            });
 
        }
            break;
            
        case 5:{
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] creatFolderWithToken:1 andDiretoryID:1 andDiretoryName:@"bbbb"];
            
            [self.socketClient writeData:data withTimeout:-1 tag:0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSData *data2 = [[ProtocolDataManager sharedProtocolDataManager] creatFolderWithToken:1 andDiretoryID:2 andDiretoryName:@"bbbb"];
                
                [self.socketClient writeData:data2 withTimeout:-1 tag:0];
            });
            
        }
          break;
        case 6:{
            
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] moveFolderWithToken:1 andParentDiretoryID:2 andDiretoryID:3];
            
            [self.socketClient writeData:data withTimeout:-1 tag:0];
        }
            break;
        case 7:{
            
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] reqDownFileDataWithUserToken:1 andFileName:@"wwww.png" andDirectoryID:1];
            
            [self.socketClient writeData:data withTimeout:-1 tag:0];
        }
            break;
        case 8:{
            
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] downFileDataWithUserToken:1 andFileID:1];
            
            [self.socketClient writeData:data withTimeout:-1 tag:0];
        }
            break;
        case 9:{
            NSData *data = [[ProtocolDataManager sharedProtocolDataManager] fileListWithToken:1 andDirectoryID:1];
            
            [self.socketClient writeData:data withTimeout:-1 tag:0];
            
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
   
    [sock readDataWithTimeout:-1 tag:tag];
}

#pragma mark 读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"当前sock  ----- %@",sock);
    NSLog(@"客户端数据长度: -- %ld" , data.length);
//    
    Byte ret;
    [[data subdataWithRange:NSMakeRange(8, 1)] getBytes:&ret length:sizeof(Byte)];
    NSLog(@"客户端接收命令: --%d",ret);
    
    [sock readDataWithTimeout:-1 tag:tag];
}

@end
