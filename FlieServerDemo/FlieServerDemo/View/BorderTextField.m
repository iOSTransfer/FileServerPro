//
//  BorderTextField.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/4.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "BorderTextField.h"

@implementation BorderTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}
@end
