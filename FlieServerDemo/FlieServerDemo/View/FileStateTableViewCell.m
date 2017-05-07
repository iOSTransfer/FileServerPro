//
//  FileStateTableViewCell.m
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/5/7.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "FileStateTableViewCell.h"
#import "socketClientManager.h"
#import "AppDataSource.h"

@interface FileStateTableViewCell ()<socketClientManagerDelegate>

@property(nonatomic,strong)CAShapeLayer *progressLayer;
@property(nonatomic ,assign)CGFloat progress;

@end

@implementation FileStateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(5, 63, [UIScreen mainScreen].bounds.size.width - 5, 1)];
    line.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0  blue:234/255.0  alpha:1];
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.lineWidth = 5;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.frame = CGRectMake(0, 0, 44, 44);
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1].CGColor;
        _progressLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 44, 44)].CGPath;
        _progressLayer.affineTransform = CGAffineTransformMakeRotation(-M_PI_2);
        [self.fileStateButton.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}




- (IBAction)tapFileUpButton:(id)sender
{
    if (_fileModel.stateType == FileStateTypeStart) {
        
        _fileModel.stateType = FileStateTypeIng;
        [self.fileStateButton setImage:[[UIImage imageNamed:@"pressed@3x"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
       
        //请求文件下载
        [socketClientManager sharedClientManager].delegate = self;
        [[socketClientManager sharedClientManager]sendReqFileupWithName:_fileModel.fileName  andDirectoryID:1 andSize:_fileModel.fileSize];
        
//        [[socketClientManager sharedClientManager] sendReqFileupWithName:_fileModel.fileName andDirectoryID:1 andSize:_fileModel.fileSize andBlock:^(ResponsType replyType, u_short key) {
//
//            NSData *filedata = [NSData dataWithContentsOfFile:_fileModel.filePath];
//            u_short chunks = filedata.length / 1024 + 1;
//            CGFloat pro = 0.0001;
//
//            dispatch_async(dispatch_queue_create("sendFile", DISPATCH_QUEUE_SERIAL), ^{
//                for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
//                    
//                    if (currentChunk == chunks) {
//                        u_short size = filedata.length % 1024;
//                        NSLog(@"%hu",size);
//                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
//                        [[socketClientManager sharedClientManager] sendFileDataWithUserToken:[AppDataSource shareAppDataSource].userToken andFileID:key andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData andBlock:^(ResponsType replyType, u_short key) {
//                            NSLog(@"replyType  ==  %d",replyType);
//                            if (replyType == ResponsTypeUpSuccess) {
//                                
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    [self.fileStateButton setTintColor:[UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1]];
//                                    [self.fileStateButton setImage:[[UIImage imageNamed:@"fileOk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//                                });
//                                
//                            }
//                            
//                        }];
//                        
//                        
//                    }else{
//                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
//                        [[socketClientManager sharedClientManager] sendFileDataWithUserToken:[AppDataSource shareAppDataSource].userToken andFileID:key andChunks:chunks andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData andBlock:^(ResponsType replyType, u_short key) {
//                            NSLog(@"replyType  ==  %d",replyType);
//                            static int count = 0;
//                            count ++;
//                            
//                        }];
//
//                        
//                    }
//                    
//                }
//            });
//
//        }];
        
    }
    
}

-(void)setFileModel:(FileStateCellModel *)fileModel
{
    _fileModel = fileModel;
    self.iconImageView.image = [UIImage imageNamed:fileModel.fileTypeImageName];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.fileNameLabel.text = fileModel.fileName;
    
    [self.fileStateButton setTintColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    [self.fileStateButton setImage:[[UIImage imageNamed:@"uploadButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.fileStateButton.layer.cornerRadius = 22;
    self.fileStateButton.layer.masksToBounds = YES;
    self.fileStateButton.layer.borderWidth = 1;
    self.fileStateButton.layer.borderColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1].CGColor;

    self.fileProgress.text = [NSString stringWithFormat:@"%.2fkb/%.2fkb",(double)fileModel.fileUpSize / 1024,(double)fileModel.fileSize / 1024];
}

#pragma mark 
- (void)receiveReplyType:(ResponsType)replyType andKey:(u_short)key andCmd:(CmdType)cmd
{
    switch (cmd) {
        case CmdTypeReqUp:{
            NSData *filedata = [NSData dataWithContentsOfFile:_fileModel.filePath];
            u_short chunks = filedata.length / 1024 + 1;
            _fileModel.totalChunk = chunks;
            _fileModel.chunkSize = 1024;
            dispatch_async(dispatch_queue_create("sendFile", DISPATCH_QUEUE_SERIAL), ^{
                for (u_short currentChunk = 1; currentChunk <= chunks; currentChunk++) {
                    
                    if (currentChunk == chunks) {
                        u_short size = filedata.length % 1024;
                        NSLog(@"%hu",size);
                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), size)];
                        [[socketClientManager sharedClientManager] sendFileDataWithUserToken:[AppDataSource shareAppDataSource].userToken andFileID:key andChunks:chunks andCurrentChunk:currentChunk andDataSize:size andSubFileData:subData];
                        
                    }else{
                        NSData *subData = [filedata subdataWithRange:NSMakeRange(0 + 1024 * (currentChunk - 1), 1024)];
                        [[socketClientManager sharedClientManager] sendFileDataWithUserToken:[AppDataSource shareAppDataSource].userToken andFileID:key andChunks:chunks andCurrentChunk:currentChunk andDataSize:1024 andSubFileData:subData];
                        
                    }
                    
                }
            });
        }
            
            break;
        case CmdTypeUp:{
            if (replyType == ResponsTypeUpSuccess) {
                [self.fileStateButton setTintColor:[UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1]];
                [self.fileStateButton setImage:[[UIImage imageNamed:@"fileOk"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [self.progressLayer removeFromSuperlayer];
                
            }else if (replyType == ResponsTypeUping){
                
                static int  i = 0;
                i++;
                self.progressLayer.strokeEnd = i * 0.0001;
            }
            
            
        }
            
            break;
            
        default:
            break;
    }

}


@end
