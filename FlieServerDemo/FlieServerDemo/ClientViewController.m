//
//  ClientViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/20.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ClientViewController.h"
#import "GCDAsyncSocket.h"

#define HOST @"10.134.19.1"


@interface ClientViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic , strong)GCDAsyncSocket *socketServer;

@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    uint16_t prot = 6666;
    // 创建服务器
    
    self.socketServer = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSError *error;
    // 连接服务器
    [self.socketServer connectToHost:HOST onPort:prot error:&error];
    
    if (error) {
        NSLog(@"连接失败 ： %@",error);
    }else{
    
        NSLog(@"连接成功");
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    btn.center = self.view.center;
    [btn setTitle:@"发送大文件数据" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tapBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}


- (void)tapBtn
{

    NSString *path = [[NSBundle mainBundle] pathForResource:@"YYText-master" ofType:@"zip"];
     NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"错误 ： %@",error);
    }else{
        [self.socketServer writeData:data withTimeout:-1 tag:0];
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
    NSLog(@"%s",__func__);
    
    [sock readDataWithTimeout:-1 tag:tag];
}

#pragma mark 读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //代理是在主/子线程调用
    NSLog(@"%@",[NSThread currentThread]);
    
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (tag == 200) {
        //登录指令
    }else if(tag == 201){
        //聊天数据
    }
    NSLog(@"%s %@",__func__,receiverStr);
}

@end
