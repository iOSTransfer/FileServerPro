//
//  StartView.h
//  FlieServerDemo
//
//  Created by 聂自强 on 2017/4/23.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import <UIKit/UIKit.h>

#define staticColor     [UIColor colorWithRed:83/255. green:175/255. blue:132/255. alpha:1]
#define StartColor      [UIColor colorWithRed:0 green:146.0/255.0 blue:200/255.0 alpha:1]

@interface StartView : UIView

- (void)setTitle:(NSString*)title;
- (void)setTitleColor:(UIColor*)color;
- (void)setViewBackgroundColor:(UIColor*)color;
- (void)setTitleFont:(UIFont*)font;
- (void)addAction:(void(^)(void))action;
- (void)start;
- (void)stop;


@end
