//
//  ServerViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/21.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ServerViewController.h"
#import "GCDAsyncSocket.h"


@interface ServerViewController ()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableSet *clientSockets;//保存客户端scoket
@property (strong,nonatomic) NSMutableData *receiveData;


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
    UIButton *startServer = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    startServer.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    startServer.backgroundColor = [UIColor whiteColor];
    startServer.layer.cornerRadius = 50;
    startServer.layer.masksToBounds = YES;
    [startServer addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startServer];

    
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


#pragma mark - 事件监听

- (void)buttonPressed
{
    
        //1.创建scoket对象
        GCDAsyncSocket *serviceScoket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        
        //2.绑定端口(6666)
        NSError *error = nil;
        [serviceScoket acceptOnPort:6666 error:&error];
        
        //3.开启服务(实质第二步绑定端口的同时默认开启服务)
        if (error == nil)
        {
            NSLog(@"开启成功");
        }
        else
        {
            NSLog(@"开启失败");
        }
        self.socket = serviceScoket;
    
    
    
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
    
    //连接成功服务端立即向客户端提供服务
    NSMutableString *serviceContent = [NSMutableString string];
    [serviceContent appendString:@"success"];
    [newSocket writeData:[serviceContent dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    //2.监听客户端有没有数据上传
    [newSocket readDataWithTimeout:-1 tag:0];
}

//接收到客户端数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"%@----",sock);
    
    NSLog(@"二进制流数据: -- %@" , data);
    
    
    //1.接受到用户数据
    
    
    static BOOL isFile = NO;
    static NSUInteger fileLength = 0;
    
    NSData *fffData = [data subdataWithRange:NSMakeRange(0, 7)];
    NSString *fff = [[NSString alloc]initWithData:fffData encoding:NSUTF8StringEncoding];
    
    
    
    
    if ([fff isEqualToString:@"FFF=1.0"]) {
        
        NSData *typeData = [data subdataWithRange:NSMakeRange(7, 4)];
        int type;
        [typeData getBytes: &type length: sizeof(type)];
        
        
        NSLog(@"%lu",(unsigned long)type);
        switch (type) {
            case 1:{
                
                NSData *lenData = [data subdataWithRange:NSMakeRange(11, 8)];
                NSUInteger len;
                [lenData getBytes: &len length: sizeof(len)];
                
                fileLength = len;
                NSLog(@"%@" ,lenData);
                NSLog(@"%ld" ,len);
                if (fileLength) {
                    isFile = YES;
                }
            }
                break;
                
            default:
                break;
        }
        
    }
    
    if (self.receiveData.length < fileLength) {
        
        [self.receiveData appendData:data];
        NSLog(@"----------------%ld" ,self.receiveData.length);
        if (fileLength == self.receiveData.length - 19) {
            
            NSString * destPath= NSHomeDirectory();
            NSString * strDir=[destPath stringByAppendingPathComponent:@"Documents"];
            NSString * de=[strDir stringByAppendingPathComponent:@"nzq00.mp4"];
            NSLog(@"'%@",de);
            
            NSData *subData = [self.receiveData subdataWithRange:NSMakeRange(19, fileLength)];
            BOOL isSuccess = [subData writeToFile:de atomically:YES];
            NSLog(@"%d",isSuccess)              ;
            
            
            NSLog(@"%lu",(unsigned long)self.receiveData.length);
        }
        
    }
    
    
    
    
    
    //处理请求 返回数据
    //    [sock writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:60 tag:0];
    
    //    if (str.length == 0) {
    //        [self.clientSockets removeObject:sock];
    //    }
    //CocoaAsyncSocket每次读取完成后必须调用一次监听数据方法
    [sock readDataWithTimeout:-1 tag:0];
}




//设置StatusBar的样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
