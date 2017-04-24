//
//  AppDataSource.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/4/23.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataSource : NSObject

+ (instancetype)shareAppDataSource;

//获取IP地址
- (NSString *)deviceIPAdress;

@end
