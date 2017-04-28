//
//  ReqDownFileInfo.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/28.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReqDownFileInfo : NSObject

@property(nonatomic , assign)u_short userToken;
@property(nonatomic , assign)Byte fileNameLength;   //文件名长度
@property(nonatomic , copy)NSString *fileName;      //文件名
@property(nonatomic , assign)u_short directoryID;   //文件夹ID


@end
