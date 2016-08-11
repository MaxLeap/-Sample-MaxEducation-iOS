//
//  MECourseGroupCell.m
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MECourseGroupCell.h"

NSString * const kInfoImgURL = @"infoImg";
NSString * const kInfoCourseName = @"infoCourseName";
NSString * const kInfoSubTitle = @"infoDes";
NSString * const kInfoCourseCount = @"infoCourseCount";

@interface MECourseGroupCell ()
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) UIButton *addCourseBtn;
@end

@implementation MECourseGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    self.desLabel = [[UILabel alloc] init];
    self.desLabel.textColor = UIColorFromRGBA(0, 0, 0, 0.6);
    [self.contentView addSubview:self.desLabel];
    
    self.addCourseBtn = [[UIButton alloc] init];
    [self.addCourseBtn setImage:ImageNamed(@"icn_addchapter") forState:UIControlStateNormal];
    [self.addCourseBtn addTarget:self action:@selector(addCourseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.addCourseBtn.hidden = YES;
    [self.contentView addSubview:self.addCourseBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat imgH = height - border * 2;
    self.imageView.frame = CGRectMake(border, border, 140, imgH);
    
    CGFloat labelX = CGRectGetMaxX(self.imageView.frame) + 10;
    CGFloat labelW = width - border * 2 - 140 - 10;
    CGFloat labelH = 30;
    self.textLabel.frame = CGRectMake(labelX, 15, labelW, labelH);
    
    self.desLabel.frame = CGRectMake(labelX, height - border - labelH, labelW, labelH);
    
    CGFloat btnW = 25;
    CGFloat btnX = width - border - btnW;
    CGFloat btnY = (height - btnW) / 2;
    self.addCourseBtn.frame = CGRectMake(btnX, btnY, btnW, btnW);
}

- (void)updateContentWithInfo:(NSDictionary *)info {
    NSURL *imgURL = [NSURL URLWithString:info[kInfoImgURL]];
    [self.imageView sd_setImageWithURL:imgURL placeholderImage:ImageNamed(@"default")];
    
    self.textLabel.text = info[kInfoCourseName];
    
    self.desLabel.text = info[kInfoSubTitle];
}

- (void)setAddCourseBlock:(dispatch_block_t)addCourseBlock {
    _addCourseBlock = addCourseBlock;
    self.addCourseBtn.hidden = NO;
}

- (void)addCourseBtnAction:(UIButton *)sender {
    if (self.addCourseBlock) {
        self.addCourseBlock();
    }
}

@end
