//
//  AppDataSource.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/4/23.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataSource : NSObject


@property (nonatomic , strong)NSMutableArray *currentUsers;  //当前在线用户


+ (instancetype)shareAppDataSource;

//获取IP地址
- (NSString *)deviceIPAdress;

@end
