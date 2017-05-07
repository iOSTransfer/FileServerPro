//
//  UpFileViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/5.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "UpFileViewController.h"
#import "FileStateCellModel.h"
#import "FileStateTableViewCell.h"

// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR(_r,_g,_b) [UIColor colorWithRed:_r / 255.0f green:_g / 255.0f blue:_b / 255.0f alpha:1]

@interface UpFileViewController ()<UITableViewDataSource,UITableViewDelegate>{

    UITableView *upfilesTable;
}

@property (nonatomic , strong)NSArray *menuItems;
@property (nonatomic , strong)UIImageView *backImageView;
@property (nonatomic , strong)NSMutableArray *dataArray;

@end

@implementation UpFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"上传列表";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //创建设备tableView
    upfilesTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    upfilesTable.delegate = self;
    upfilesTable.dataSource =self;
    upfilesTable.showsVerticalScrollIndicator = NO;
    upfilesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *nib = [UINib nibWithNibName:@"FileStateTableViewCell" bundle:nil];
    [upfilesTable registerNib:nib forCellReuseIdentifier:@"fileUpCell"];
    [self.view addSubview:upfilesTable];
    

    
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        //模拟数据

        FileStateCellModel *model = [FileStateCellModel new];
        model.fileName = [NSString stringWithFormat:@"图片%d.jpg",arc4random() % 100000];
        model.fileTypeImageName = @"ico_photos_small@3x";
        model.stateType = FileStateTypeStart;
        model.fileUpSize = 0;
        model.fileSize = [self getFileSizeWithName:@"BBB" andType:@"jpg"];
        model.filePath = [[NSBundle mainBundle] pathForResource:@"BBB" ofType:@"jpg"];
        [_dataArray addObject:model];
        
        FileStateCellModel *model0 = [FileStateCellModel new];
        model0.fileName = [NSString stringWithFormat:@"图片%d.jpg",arc4random() % 100000];
        model0.fileTypeImageName = @"ico_photos_small@3x";
        model0.stateType = FileStateTypeStart;
        model0.fileUpSize = 0;
        model0.fileSize = [self getFileSizeWithName:@"timg" andType:@"jpeg"];
        model0.filePath = [[NSBundle mainBundle] pathForResource:@"timg" ofType:@"jpeg"];
        [_dataArray addObject:model0];
        
        FileStateCellModel *model1 = [FileStateCellModel new];
        model1.fileName = [NSString stringWithFormat:@"视屏%d.mp4",arc4random() % 100000];
        model1.fileTypeImageName = @"ico_swf_small@3x";
        model1.stateType = FileStateTypeStart;
        model1.fileSize = [self getFileSizeWithName:@"NZQ" andType:@"mp4"];
        model1.fileUpSize = 0;
        model1.filePath = [[NSBundle mainBundle] pathForResource:@"NZQ" ofType:@"mp4"];
        [_dataArray addObject:model1];
        
        
        FileStateCellModel *model2 = [FileStateCellModel new];
        model2.fileName = [NSString stringWithFormat:@"归档%d.zip",arc4random() % 100000];
        model2.fileTypeImageName = @"ico_zip_small@3x";
        model2.stateType = FileStateTypeStart;
        model2.fileSize =  [self getFileSizeWithName:@"地中海" andType:@"zip"];
        model2.fileUpSize = 0;
        model2.filePath = [[NSBundle mainBundle] pathForResource:@"地中海" ofType:@"zip"];
        [_dataArray addObject:model2];
        
    }
    return _dataArray;
}

- (u_int)getFileSizeWithName:(NSString *)name andType:(NSString *)fileType;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:fileType];
    NSData *filedata = [NSData dataWithContentsOfFile:path];
    return (u_int)filedata.length;
}



#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileStateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileUpCell"];
    cell.fileModel = _dataArray[indexPath.row];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


@end
