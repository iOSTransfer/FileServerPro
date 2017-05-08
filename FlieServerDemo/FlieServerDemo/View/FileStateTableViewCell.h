//
//  FileStateTableViewCell.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/5/7.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileStateCellModel.h"

@class FileStateTableViewCell;

@protocol FileStateTableViewCellDelegate <NSObject>

- (void)tapUpfileButton:(FileStateTableViewCell *)cell;

@end

@interface FileStateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileProgress;
@property (weak, nonatomic) IBOutlet UIButton *fileStateButton;

@property(nonatomic,strong)CAShapeLayer *progressLayer;
@property(nonatomic ,assign)CGFloat subProgress;
@property(nonatomic ,assign)int subProgressCount;

@property (nonatomic , strong)FileStateCellModel *fileModel;

@property (weak , nonatomic) id<FileStateTableViewCellDelegate> delegate;

@end
