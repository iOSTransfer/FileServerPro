//
//  HeaderInfo.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/25.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumList.h"

@interface HeaderInfo : NSObject

@property(nonatomic , assign)CmdType cmd;
@property(nonatomic , assign)Byte ver;
@property(nonatomic , assign)uint c_length;

@end
