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

// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define COLOR(_r,_g,_b) [UIColor colorWithRed:_r / 255.0f green:_g / 255.0f blue:_b / 255.0f alpha:1]

@interface ClientMainViewController ()<UICollectionViewDelegate , UICollectionViewDataSource>

@end

@implementation ClientMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"客户端";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setHidesBackButton:YES];
    
    [self setUI];
}

- (void)setUI
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 164)];
    headerView.backgroundColor = COLOR(220, 220, 220);
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
    layout.itemSize =  CGSizeMake(SCREEN_WIDTH  / 4.0, 110);

    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 164, SCREEN_WIDTH, SCREEN_HEIGHT - 164)];
    UINib *nib = [UINib nibWithNibName:@"MineCollectionViewCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"mainCell"];
    [collectionView registerClass:[TitleReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [collectionView registerClass:[TitleReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"header"];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];


}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
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


    return cell;
}

@end
