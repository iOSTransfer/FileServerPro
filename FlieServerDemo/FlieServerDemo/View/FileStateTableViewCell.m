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



@end

@implementation FileStateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(5, 63, [UIScreen mainScreen].bounds.size.width - 5, 1)];
    line.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0  blue:234/255.0  alpha:1];
    [self addSubview:line];
    self.subProgressCount = 0;

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
       
        if ([self.delegate respondsToSelector:@selector(tapUpfileButton:)]) {
            [self.delegate tapUpfileButton:self];
        }
 
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

    self.fileProgress.text = [NSString stringWithFormat:@"%.2fkb/%.2fkb",fileModel.fileUpSize ,fileModel.fileSize];
    
}




@end
