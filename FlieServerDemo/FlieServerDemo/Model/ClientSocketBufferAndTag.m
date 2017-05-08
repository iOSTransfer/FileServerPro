//
//  ClientSocketBufferAndTag.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/8.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "ClientSocketBufferAndTag.h"

@implementation ClientSocketBufferAndTag

- (NSMutableData *)readBuff
{
    if (_readBuff == nil) {
        _readBuff = [[NSMutableData alloc]init];
    }
    
    return _readBuff;
    
}

@end
