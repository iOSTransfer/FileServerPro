//
//  ClientSocketBufferAndTag.h
//  FlieServerDemo
//
//  Created by lyric on 2017/5/8.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientSocketBufferAndTag : NSObject

@property (nonatomic , strong)NSMutableData *readBuff;
@property (nonatomic , assign)NSUInteger tag;

@end
