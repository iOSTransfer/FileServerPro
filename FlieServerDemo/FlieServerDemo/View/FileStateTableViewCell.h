//
//  FileStateTableViewCell.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/5/7.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileStateCellModel.h"

@interface FileStateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileProgress;
@property (weak, nonatomic) IBOutlet UIButton *fileStateButton;

@property (nonatomic , strong)FileStateCellModel *fileModel;

@end
