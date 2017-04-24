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

@interface ClientViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic , strong)GCDAsyncSocket *socketClient;


@end

@implementation ClientViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"客户端";
    
    NSArray *titileArray = @[@"请求连接" ,@"发送登录信息",@"发送大文件",@"并发发送大文件"];
    self.view.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < titileArray.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.bounds = CGRectMake(0, 0, 300, 30);
        button.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, 150 + i *60);
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
            self.socketClient = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            
            
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
            
            
            UserInfo *user = [[UserInfo alloc]init];
            user.userName = @"我啊";
            user.userPwd = @"222222";
            NSLog(@"%@",user.yy_modelToJSONString );
            NSData  *data = user.yy_modelToJSONData;
            
            
            
//            NSDictionary *dic = @{@"fileName":@"sbs",@"fileID":@"55555" };
//            NSDictionary *dic2 = @{@"fileName":@"aaaaa",@"fileID":@"22222" };
//            NSDictionary *dic3 = @{@"fileName":@"vvvvvv",@"fileID":@"000000" };
//            
//            
//            NSArray *arr = @[dic,dic2,dic3];
//            NSLog(@"%@",arr);

            
            NSString *str = @"FFF";
            NSData *strdata = [str dataUsingEncoding:NSUTF8StringEncoding];

            int type = 1;
            
            
            NSUInteger length = data.length;
            NSLog(@"%ld",length);
            
            NSData *data11 = [NSData dataWithBytes:&type length:sizeof(type)];
            NSData *data22 = [NSData dataWithBytes:&length length:sizeof(length)];
            NSLog(@"%ld",data11.length);
            NSLog(@"%ld",data22.length);
            
            
            NSMutableData *muData = [NSMutableData data];
            
            [muData appendData:strdata];
            [muData appendBytes:&type length:sizeof(type)];
            [muData appendBytes:&length length:sizeof(length)];
            [muData appendData:data];
            
            [self.socketClient writeData:muData withTimeout:-1 tag:0];
        
        }
            break;
        case 2:{
            NSString *path = [[NSBundle mainBundle] pathForResource:@"NZQ" ofType:@"mp4"];
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
            
        }
            break;
        case 3:{
            
            
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
