//
//  MainTabBarViewController.m
//  FlieServerDemo
//
//  Created by lyric on 2017/4/21.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "ServerViewController.h"
#import "ClientViewController.h"
#import "BaseNavViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加服务器
    [self addChildViewController:[[BaseNavViewController alloc]initWithRootViewController:[ServerViewController new]] andImageName:@"tabar2@3x" selectedName:@"服务器"];
    
    //添加客户端
    [self addChildViewController:[[BaseNavViewController alloc]initWithRootViewController:[ClientViewController new]] andImageName:@"tabar1@3x" selectedName:@"客户端"];
    
    self.tabBar.tintColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1];
    self.tabBar.translucent = NO;
    
    
}



//tabarViewController添加控制器
- (void)addChildViewController:(UINavigationController *)childController andImageName:(NSString  *)name selectedName:(NSString *)selectName
{
    
    childController.tabBarItem.image = [UIImage imageNamed:name];
    childController.tabBarItem.selectedImage = [UIImage imageNamed:selectName];
    childController.tabBarItem.title = selectName;
    [self addChildViewController:childController];
}



@end
