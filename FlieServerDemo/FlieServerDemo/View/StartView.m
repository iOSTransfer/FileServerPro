//
//  StartView.m
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/4/23.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "StartView.h"



@interface StartView()
{
    dispatch_block_t    _myblock;
    UIView              *vTap;
    UIImageView         *imageLoad;
    UILabel             *titleLabel;
}
@end

@implementation StartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        vTap = [[UIView alloc] initWithFrame:CGRectMake(7, 7, frame.size.width - 14, frame.size.height - 14)];
        [vTap setBackgroundColor:staticColor];
        vTap.layer.cornerRadius = (frame.size.height - 14) / 2;
        vTap.layer.masksToBounds = YES;
        [self addSubview:vTap];
        
        imageLoad = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageLoad.hidden = YES;
        imageLoad.image = [UIImage imageNamed:@"start@2x"];
        [self addSubview:imageLoad];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setTitle:(NSString*)title
{
    titleLabel.text = title;
}

- (void)setTitleColor:(UIColor*)color
{
    titleLabel.textColor = color;
}

- (void)setTitleFont:(UIFont*)font
{
    titleLabel.font = font;
}

- (void)addAction:(void(^)(void))action
{
    _myblock = action;
}

- (void)setViewBackgroundColor:(UIColor*)color
{
    vTap.backgroundColor = StartColor;
}

- (void)doAction
{

    if(_myblock != NULL) {
        _myblock();
    }
    
}

- (void)start
{
    imageLoad.hidden = NO;
    vTap.backgroundColor = StartColor;
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.repeatCount = INFINITY;
    rotateAnimation.byValue = @(M_PI*2);
    rotateAnimation.duration = 1.5;
    rotateAnimation.removedOnCompletion = NO;
    [imageLoad.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];

}

- (void)stop
{
    vTap.backgroundColor = staticColor;
    [imageLoad.layer removeAllAnimations];
    imageLoad.hidden = YES;
}

@end
