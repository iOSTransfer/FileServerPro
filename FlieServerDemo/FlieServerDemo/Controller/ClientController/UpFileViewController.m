//
//  UpFileViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/5.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "UpFileViewController.h"
#import "KxMenu.h"

// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR(_r,_g,_b) [UIColor colorWithRed:_r / 255.0f green:_g / 255.0f blue:_b / 255.0f alpha:1]

@interface UpFileViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UIButton *rightButton;
    UITableView *upfilesTable;
}

@property (nonatomic , strong)NSArray *menuItems;
@property (nonatomic , strong)UIImageView *backImageView;
@property (nonatomic , strong)NSArray *dataArray;

@end

@implementation UpFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"上传列表";
    self.view.backgroundColor = COLOR(230, 230, 230);
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30,  30)];
    [rightButton setImage:[UIImage imageNamed:@"upFileIcon"] forState:UIControlStateNormal];

    [rightButton addTarget:self action:@selector(tapRightAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //创建设备tableView
    upfilesTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    upfilesTable.delegate = self;
    upfilesTable.dataSource =self;
    upfilesTable.showsVerticalScrollIndicator = NO;
    upfilesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:upfilesTable];
    
    
    //初始化右上角按钮可弹出的items
    [self initKxmenuItems];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //判断中间的添加设备按钮是否显示
    if (self.dataArray.count) {
        self.backImageView.hidden = YES;
    }else{
        self.backImageView.hidden = NO;
    }

}

//初始化右上角按钮可弹出的items
- (void)initKxmenuItems {
    
    _menuItems =
    @[
      [KxMenuItem menuItem:@"上传图片"
                     image:nil
                    target:self
                    action:@selector(upSysImages)],
      [KxMenuItem menuItem:@"上传大文件"
                     image:nil
                    target:self
                    action:@selector(upBigFile)],
      [KxMenuItem menuItem:@"上传多个大文件"
                     image:nil
                    target:self
                    action:@selector(upSomeFiles)],

      
      ];
    
}

- (UIImageView *)backImageView
{
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
        _backImageView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"noUpFile" ofType:@"jpg"];
        NSData *imageData = [NSData dataWithContentsOfFile:path];
        _backImageView.center = upfilesTable.center;
        _backImageView.image = [UIImage imageWithData:imageData];
        [upfilesTable addSubview:_backImageView];
    }

    return _backImageView;
}

- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

#pragma mark Action

//上传文件按钮点击
- (void)tapRightAction
{
    static BOOL isShow = NO;
    
    if (!isShow) {
        isShow = YES;
        [KxMenu setTintColor:[UIColor whiteColor]];
        [KxMenu showMenuInView:self.view
                      fromRect:CGRectMake(SCREEN_WIDTH - 64, 0, 64, 1)
                     menuItems:_menuItems];
    }else{
        isShow = NO;
        [KxMenu dismissMenu];
    }

}

//上传图片- > 系统相册
- (void)upSysImages
{


}

//上传文件
- (void)upBigFile
{

}

//上传多个大文件
- (void)upSomeFiles
{

}

#pragma mark UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [UITableViewCell new];
}



@end
