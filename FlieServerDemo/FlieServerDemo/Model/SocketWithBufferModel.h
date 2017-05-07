//
//  SocketWithBufferModel.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/5/6.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SocketWithBufferModel : NSObject

@property (nonatomic ,strong)GCDAsyncSocket *clientSocket;
@property (nonatomic , strong)NSMutableData *readBuff;

@end
