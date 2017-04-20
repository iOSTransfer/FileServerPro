//
//  ViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/20.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "GCDAsyncSocket.h"
#import "ClientViewController.h"


@interface ViewController ()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableSet *clientSockets;//保存客户端scoket

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"服务器管理界面";
    
    NSArray *titileArray = @[@"开启服务",@"进入客户端"];
    self.view.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < titileArray.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.bounds = CGRectMake(0, 0, 300, 30);
        button.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, 150 + i *60);
        [button setTitle:titileArray[i] forState:UIControlStateNormal];
        button.tag =  10+i;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

#pragma mark -懒加载
- (NSMutableSet *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [[NSMutableSet alloc]init];
    }
    return _clientSockets;
}



#pragma mark - 事件监听

- (void)buttonPressed:(UIButton *)sender
{
    
    if (sender.tag == 10) {
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
    }else{
    
        [self.navigationController pushViewController:[ClientViewController new] animated:YES];
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
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    //处理请求 返回数据
    [sock writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:60 tag:0];
    
    if (str.length == 0) {
        [self.clientSockets removeObject:sock];
    }
    //CocoaAsyncSocket每次读取完成后必须调用一次监听数据方法
    [sock readDataWithTimeout:-1 tag:0];
}


#pragma mark - other

- (UIViewController *)getViewcontrolWithName:(NSString *)name
{
    //类名(对象名)
    NSString *class = name;
    const char *className = [class cStringUsingEncoding:NSASCIIStringEncoding];
    Class newClass = objc_getClass(className);
    if (!newClass) {
        //创建一个类
        Class superClass = [NSObject class];
        newClass = objc_allocateClassPair(superClass, className, 0);
        //注册你创建的这个类
        objc_registerClassPair(newClass);
    }
    // 创建对象
    UIViewController *instance = [[newClass alloc] init];
    return instance;
}





@end
