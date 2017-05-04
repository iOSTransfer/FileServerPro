//
//  AppDataSource.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/4/23.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumList.h"

@interface AppDataSource : NSObject

+ (instancetype)shareAppDataSource;

#pragma mark 服务端使用

@property (nonatomic , strong)NSMutableSet *currentUsers;  //当前在线用户

//获取IP地址
- (NSString *)deviceIPAdress;

//返回手机剩余空间(b)
- (double)freeDiskSpaceInBytes;

#pragma mark 客户端使用

@property (nonatomic , assign)u_short userToken;

//响应码转详细信息
- (NSString *)getStringWithRte:(ResponsType)type;


@end
