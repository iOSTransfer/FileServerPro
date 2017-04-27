//
//  FileChunkInfo.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/27.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileChunkInfo : NSObject

@property(nonatomic , assign)u_short userToken;
@property(nonatomic , assign)u_short fileID;
@property(nonatomic , assign)u_short chunks;
@property(nonatomic , assign)u_short chunk;
@property(nonatomic , assign)u_short size;

@property(nonatomic , strong)NSData *subData;



@end
