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
#import "UserInfo.h"
#import "ProtocolDataManager.h"
#import "DataBaseManager.h"
#import "EnumList.h"
#import "SocketServerManager.h"


@interface ServerViewController ()<GCDAsyncSocketDelegate>{

    UILabel *currentSocketsLabel;
    UILabel *diskSpaceLabel;
    
}
@property (strong, nonatomic) StartView *startServer;
@property (strong, nonatomic) NSMutableArray *itemArray;

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1];
    self.navigationItem.title = @"服务器";
    self.itemArray = [NSMutableArray array];
    [self setUI];
}

- (void)setUI
{
    
    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width, 24)];
    
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:14];
    NSString *infoString = [NSString stringWithFormat:@"IP地址:%@ 端口号:6666",[[AppDataSource shareAppDataSource] deviceIPAdress]];
    infoLabel.text = infoString;
    [self.view addSubview:infoLabel];
    
    diskSpaceLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(infoLabel.frame), [UIScreen mainScreen].bounds.size.width * 0.5, 24)];
    diskSpaceLabel.textColor = [UIColor whiteColor];
    diskSpaceLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:diskSpaceLabel];
    [self upateDiskSpaceLabelText];
    
    currentSocketsLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5, CGRectGetMaxY(infoLabel.frame), [UIScreen mainScreen].bounds.size.width * 0.5 - 10, 24)];
    currentSocketsLabel.textColor = [UIColor whiteColor];
    currentSocketsLabel.font = [UIFont systemFontOfSize:14];
    currentSocketsLabel.hidden = YES;
    currentSocketsLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:currentSocketsLabel];
    
    
    
    self.startServer = [[StartView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.startServer.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    [self.startServer setTitle:@"Start"];
    __weak typeof (ServerViewController *)weakSelf = self;
    [self.startServer addAction:^{
        [weakSelf openServer];
    }];
    [self.view addSubview:self.startServer];
    
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:NOTIFIER_STRING object:nil];
    

}


#pragma mark 接收通知
- (void)receiveNotification:(NSNotification *)noti
{
    if (noti.object != nil) {
        NSInteger count = [noti.object integerValue];
        [self setCurrentLabelText:count];
        
    }else{
        [self upateDiskSpaceLabelText];
    }

}


#pragma mark 服务器信息输出
- (void)setCurrentLabelText:(NSInteger )count
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"当前链接数量:  %ld",(long)count]];
        NSRange range1 = NSMakeRange(0, 9);
        NSRange range2 = NSMakeRange(9 , attributedString.length - 9);
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range1];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:250/255. green:172/255. blue:28/255. alpha:1] range:range2];
        currentSocketsLabel.attributedText = attributedString;
    });

}

- (void)upateDiskSpaceLabelText
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"剩余磁盘空间:  %0.2fGB",[[AppDataSource shareAppDataSource] freeDiskSpaceInBytes]/1024 /1024 /1024]];
        NSRange range1 = NSMakeRange(0, 9);
        NSRange range2 = NSMakeRange(9 , attributedString.length - 9);
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range1];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:250/255. green:172/255. blue:28/255. alpha:1] range:range2];
        diskSpaceLabel.attributedText = attributedString;
    });
}


#pragma mark - 事件监听

- (void)openServer
{
    //开启服务
    static BOOL isOpen = NO;
    
    if (isOpen) {
        isOpen = ![[SocketServerManager sharedServerManager] closeServer];
        [self.startServer stop];
        [self.startServer setTitle:@"Start"];
        currentSocketsLabel.hidden = YES;
    }else{
        isOpen = [[SocketServerManager sharedServerManager] openServer];
        [self.startServer start];
        [self.startServer setTitle:@"Success"];
        currentSocketsLabel.hidden = NO;
    }
 

}

//删除通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//设置StatusBar的样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
