//
//  BaseNavViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/21.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "BaseNavViewController.h"


// 屏幕宽度、高度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface BaseNavViewController ()

@end

@implementation BaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    self.navigationBar.tintColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1];
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18.0f]}];
    self.navigationBar.barTintColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1];
    self.navigationBar.translucent = NO;
    
    
//    CGSize imageSize = CGSizeMake(SCREEN_WIDTH, 64);
//    UIGraphicsImageRenderer *render = [[UIGraphicsImageRenderer alloc]initWithSize:imageSize];
//    UIImage *image = [render imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
//        UIColor *imageColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1];
//        [imageColor setFill];
//        [rendererContext fillRect:rendererContext.format.bounds];
//    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//设置StatusBar的样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
