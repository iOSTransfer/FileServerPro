//
//  SourceModel.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/28.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SourceModel : NSObject

@property (nonatomic ,assign)Byte type;         //0 文件夹 1文件
@property (nonatomic ,assign)u_short sourceID;
@property (nonatomic ,strong)NSString *sourceName;

@end
