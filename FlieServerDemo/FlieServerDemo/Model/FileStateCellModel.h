//
//  FileStateCellModel.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/5/7.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FileStateType) {
    FileStateTypeStart      = 0,        //初始状态
    FileStateTypeIng        = 1,        //传输中
    FileStateTypeSuspend    = 2,        //传输暂停
    FileStateTypeFinish     = 3,        //传输完成
    FileStateTypeError      = 4,        //传输出错
    
};


@interface FileStateCellModel : NSObject

@property (nonatomic , strong)NSString *fileName;
@property (nonatomic , strong)NSString *fileTypeImageName;
@property (nonatomic , strong)NSString *filePath;
@property (nonatomic , assign)FileStateType stateType;
@property (nonatomic , assign)double fileSize;
@property (nonatomic , assign)double fileUpSize;
@property (nonatomic , assign)u_short totalChunk;
@property (nonatomic , assign)u_short chunkSize;
@property (nonatomic , assign)u_short fileId;


@end
