//
//  DataBaseManager.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/24.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseManager : NSObject

+ (instancetype)sharedDataBase;

//添加用户注册信息
- (BOOL)addUserInfoWithName:(NSString*)userName andPwd:(NSString*)password;

@end
