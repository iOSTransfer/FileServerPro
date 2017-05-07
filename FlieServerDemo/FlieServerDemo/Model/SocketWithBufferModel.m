//
//  SocketWithBufferModel.m
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/5/6.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "SocketWithBufferModel.h"

@implementation SocketWithBufferModel

- (NSMutableData *)readBuff
{
    if (_readBuff == nil) {
        _readBuff = [[NSMutableData alloc]init];
    }
    
    return _readBuff;

}

@end
