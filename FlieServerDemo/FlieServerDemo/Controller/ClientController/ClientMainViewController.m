//
//  ClientMainViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/4.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ClientMainViewController.h"
#import "MineCollectionViewCell.h"
#import "TitleReusableView.h"

#import "DownFileViewController.h"
#import "UpFileViewController.h"


// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR(_r,_g,_b) [UIColor colorWithRed:_r / 255.0f green:_g / 255.0f blue:_b / 255.0f alpha:1]

@interface ClientMainViewController ()<UICollectionViewDelegate , UICollectionViewDataSource>

@property (nonatomic , strong)NSArray *imgNameArray;
@property (nonatomic , strong)NSArray *titleArray;

@end

@implementation ClientMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"客户端";
    self.view.backgroundColor = COLOR(240, 240, 240);
    [self.navigationItem setHidesBackButton:YES];
    
    [self setUI];
}

- (void)setUI
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 164)];
    headerView.backgroundColor = COLOR(240, 240, 240);
    [self.view addSubview:headerView];
    
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
    icon.layer.cornerRadius = 32;
    icon.layer.masksToBounds = YES;
    icon.image = [UIImage imageNamed:@"shocking@3x"];
    icon.center = CGPointMake(SCREEN_WIDTH /2, 164 /2);
    [headerView addSubview:icon];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 44);
    layout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, 21);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize =  CGSizeMake(SCREEN_WIDTH  / 4.0, 90);

    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 164, SCREEN_WIDTH, SCREEN_HEIGHT - 164 - 64) collectionViewLayout:layout];
    UINib *nib = [UINib nibWithNibName:@"MineCollectionViewCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"mainCell"];
    [collectionView registerClass:[TitleReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [collectionView registerClass:[TitleReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    collectionView.backgroundColor = COLOR(240, 240, 240);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    
    self.imgNameArray = @[@"download@3x",@"sources@3x",@"addFolder",@"removeFolder",@"mine_uperCenter@3x",@"upload@3x",@"mine_intergal@3x",@"mine_theme@3x",@"mine_pocketcenter@3x",@"mine_history@3x"];
    self.titleArray = @[@"文件下载",@"资源管理",@"创建文件夹",@"删除文件夹",@"uper",@"文件上传",@"本地文件",@"没有了",@"没有了",@"没有了"];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainCell" forIndexPath:indexPath];
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = COLOR(234, 234, 234).CGColor;
    if (indexPath.row < 5) {
        [cell.iconImageView setImage:[UIImage imageNamed:_imgNameArray[indexPath.row + indexPath.section * 5]]];
        cell.titleLabel.text = _titleArray[indexPath.row + indexPath.section * 5];
    }else{
        cell.iconImageView.hidden = YES;
        cell.titleLabel.hidden = YES;
    }
    

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *kindView;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        kindView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        UIView *view = [kindView viewWithTag:0];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [kindView viewWithTag:1];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.frame = CGRectMake(20, 0, SCREEN_WIDTH -20, 44);
        
        if (indexPath.section == 0) {
            titleLabel.text = @"网盘资源";
        }else{
            titleLabel.text = @"本地资源";
        }
        
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
    
        kindView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        UIView *view = [kindView viewWithTag:0];
        view.backgroundColor = COLOR(240, 240, 240);
    }

    return kindView;
    
}

#pragma mark 
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self.navigationController pushViewController:[DownFileViewController new] animated:YES];
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            case 3:
                
                break;
            case 4:
                
                break;
                
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                [self.navigationController pushViewController:[UpFileViewController new] animated:YES];
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            case 3:
                
                break;
            case 4:
                
                break;
                
            default:
                break;
        }
    
    }
    
    


}


@end
