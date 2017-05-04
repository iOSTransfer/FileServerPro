//
//  TitleReusableView.m
//  FlieServerDemo
//
//  Created by lyric on 2017/5/4.
//  Copyright © 2017年 lyric. All rights reserved.
//

#import "TitleReusableView.h"

@implementation TitleReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if (self.nameLabel == nil) {
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.tag = 1;
        
    }
    [self addSubview:_nameLabel];
}

@end
