//
//  MECourseCateButton.m
//  MaxEducation
//
//  Created by luomeng on 16/6/22.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MECourseCateButton.h"

@implementation MECourseCateButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat imgContainerH = height * 0.7;
    CGFloat imgW = 35;
    self.imageView.frame = CGRectMake((width - imgW) / 2, (imgContainerH - imgW) / 2, imgW, imgW);
    self.titleLabel.frame = CGRectMake(0, imgContainerH, width, height - imgContainerH);
    
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end
