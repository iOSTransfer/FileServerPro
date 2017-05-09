//
//  DownFileViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/9.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "DownFileViewController.h"
#import "FileStateCellModel.h"
#import "FileStateTableViewCell.h"
#import "socketClientManager.h"
#import "AppDataSource.h"
// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR(_r,_g,_b) [UIColor colorWithRed:_r / 255.0f green:_g / 255.0f blue:_b / 255.0f alpha:1]



@interface DownFileViewController ()<UITableViewDataSource,UITableViewDelegate,socketClientManagerDelegate,FileStateTableViewCellDelegate>{
    
    UITableView *upfilesTable;
}

@property (nonatomic , strong)NSArray *menuItems;
@property (nonatomic , strong)UIImageView *backImageView;
@property (nonatomic , strong)NSMutableArray *dataArray;
@property (nonatomic , strong)NSMutableArray *taskArray;

@end

@implementation DownFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"下载列表";
    self.view.backgroundColor = [UIColor whiteColor];
    self.taskArray = [NSMutableArray array];
    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"全部开始" style:UIBarButtonItemStyleDone target:self action:@selector(tapRightAction)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    
}


@end
