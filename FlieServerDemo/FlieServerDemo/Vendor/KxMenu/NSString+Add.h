//
//  NSString+Add.h
//  HotWindPro
//
//  Created by lyric on 2017/3/29.
//  Copyright © 2017年 lyice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Add)

//计算文字size
- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

//计算文字宽
- (CGFloat)widthForFont:(UIFont *)font;

//计算文字高
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;

//格式化序列号
+ (NSString *)getStringWithSerialID:(NSUInteger )seriaID;

@end
