//
//  MEHomeCourseListCell.m
//  MaxEducation
//
//  Created by luomeng on 16/6/21.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEHomeCourseListCell.h"

@interface MEHomeCourseListCell ()
@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UILabel *courseNameLabel;
@property (nonatomic, strong) UILabel *courseDesLabel;
@property (nonatomic, strong) UILabel *learnedLabel;
@end

@implementation MEHomeCourseListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 13;
    CGFloat imgW = 140;
    self.coverImgView.frame = CGRectMake(border, border, imgW, (height - border * 2));

    CGFloat labelX = CGRectGetMaxX(self.coverImgView.frame) + 10;
    CGFloat labelW = width - labelX - border;
    self.courseNameLabel.frame = CGRectMake(labelX, border, labelW, 20);
    
    CGFloat desLabelY = CGRectGetMaxY(self.courseNameLabel.frame) + 3;
    CGFloat desLabelH = 35;
    self.courseDesLabel.frame = CGRectMake(labelX, desLabelY, labelW, desLabelH);
    
    CGFloat learnedY = CGRectGetMaxY(self.courseDesLabel.frame) + 3;
    self.learnedLabel.frame = CGRectMake(labelX, learnedY, labelW, 16);
}

- (void)updateContentWithCourse:(MLObject *)courseGroupObj {
    NSURL *coverImgURL = [NSURL URLWithString:courseGroupObj[@"coverImgURL"]];
    [self.coverImgView sd_setImageWithURL:coverImgURL placeholderImage:ImageNamed(@"default")];
    self.courseNameLabel.text = courseGroupObj[@"groupName"];
    self.courseDesLabel.text = courseGroupObj[@"courseDes"];
    self.learnedLabel.text = [NSString stringWithFormat:@"%@人学过", courseGroupObj[@"learnedCount"]];
}

#pragma mark - build UI
- (void)initSubViews {
    self.coverImgView = [[UIImageView alloc] init];
    self.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImgView.clipsToBounds = YES;
    
    self.courseNameLabel = [[UILabel alloc] init];
    self.courseNameLabel.font = [UIFont systemFontOfSize:15];
    
    self.courseDesLabel = [[UILabel alloc] init];
    self.courseDesLabel.numberOfLines = 2;
    self.courseDesLabel.font = [UIFont systemFontOfSize:13];
    self.courseDesLabel.textColor = UIColorFromRGBA(188, 189, 190, 0.8);
    
    self.learnedLabel = [[UILabel alloc] init];
    self.learnedLabel.font = [UIFont systemFontOfSize:13];
    self.learnedLabel.textColor = UIColorFromRGBA(188, 189, 190, 0.8);
    
    [self.contentView addSubview:self.coverImgView];
    [self.contentView addSubview:self.courseNameLabel];
    [self.contentView addSubview:self.courseDesLabel];
    [self.contentView addSubview:self.learnedLabel];
}

@end
