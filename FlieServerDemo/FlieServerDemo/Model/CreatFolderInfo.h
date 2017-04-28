//
//  CreatFolderInfo.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/28.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreatFolderInfo : NSObject

@property(nonatomic , assign)u_short userToken;
@property(nonatomic , assign)u_short diretoryID;
@property(nonatomic , assign)Byte nameLength;
@property(nonatomic , copy)NSString *diretoryName;

@end
