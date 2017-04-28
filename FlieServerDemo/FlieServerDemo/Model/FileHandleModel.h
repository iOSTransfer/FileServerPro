//
//  FileHandleModel.h
//  FlieServerDemo
//
//  Created by lyric on 2017/4/28.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandleModel : NSObject

@property (nonatomic ,assign)u_short fileID;
@property (nonatomic ,strong)NSFileHandle *fileHandle;
@property (nonatomic ,strong)NSString *filePath;
@property (nonatomic ,strong)NSString *toFilePath;
@end
