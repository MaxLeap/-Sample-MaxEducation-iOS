//
//  MECourseDescCell.m
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MECourseDescCell.h"

NSString * const kDesTitle = @"desTitle";
NSString * const kDesContent = @"desContent";
NSString * const kDesTeacher = @"desTeacher";

@interface MECourseDescCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;
@end

@implementation MECourseDescCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.titleLabel = [[UILabel alloc] init];
    
    self.desLabel = [[UILabel alloc] init];
    self.desLabel.numberOfLines = 0;
    self.desLabel.textColor = UIColorFromRGBA(0, 0, 0, 0.8);
    self.desLabel.font = [UIFont systemFontOfSize:15];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.desLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat labelW = width - border * 2;
    self.titleLabel.frame = CGRectMake(border, border, labelW, 21);
    
    CGFloat desLabelH = height - border * 2 - 21 - 5;
    CGFloat desLabelY = CGRectGetMaxY(self.titleLabel.frame) + 5;
    self.desLabel.frame = CGRectMake(border, desLabelY, labelW, desLabelH);
}

+ (CGFloat)cellHeightForDesContent:(NSString *)desContent {
    CGFloat txtW = CGRectGetWidth([UIScreen mainScreen].bounds) - 15 * 2;
    CGRect rect = [desContent boundingRectWithSize:CGSizeMake(txtW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
    
    return rect.size.height + 15 * 2 + 21 + 5;
}

- (void)updateContentWithDescInfo:(NSDictionary *)desInfo {
    self.titleLabel.text = desInfo[kDesTitle];
    self.desLabel.text = desInfo[kDesContent];
}

@end


#pragma mark - MEDescTeacherCell
@interface MEDescTeacherCell ()
@property (nonatomic, strong) UILabel *desTitleLabel;
@property (nonatomic, strong) UIImageView *teacherIconView;
@property (nonatomic, strong) UILabel *teacherNameLabel;
@property (nonatomic, strong) UILabel *teacherDesLabel;
@end

@implementation MEDescTeacherCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.desTitleLabel = [[UILabel alloc] init];
    self.teacherIconView = [[UIImageView alloc] init];
    self.teacherNameLabel = [[UILabel alloc] init];
    
    self.teacherDesLabel = [[UILabel alloc] init];
    self.teacherDesLabel.font = [UIFont systemFontOfSize:15];
    self.teacherDesLabel.numberOfLines = 0;
    
    [self.contentView addSubview:self.desTitleLabel];
    [self.contentView addSubview:self.teacherIconView];
    [self.contentView addSubview:self.teacherNameLabel];
    [self.contentView addSubview:self.teacherDesLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    self.desTitleLabel.frame = CGRectMake(border, border, width - border * 2, 21);
    
    CGFloat iconY = CGRectGetMaxY(self.desTitleLabel.frame) + 10;
    CGFloat iconW = 41;
    self.teacherIconView.frame = CGRectMake(border, iconY, iconW, iconW);
    self.teacherIconView.layer.cornerRadius = iconW / 2;
    self.teacherIconView.clipsToBounds = YES;
    
    CGFloat labelX = CGRectGetMaxX(self.teacherIconView.frame) + 22;
    CGFloat labelW = width - labelX - 15;
    self.teacherNameLabel.frame = CGRectMake(labelX, iconY, labelW, iconW);
    
    CGFloat labelY = CGRectGetMaxY(self.teacherIconView.frame) + 3;
    CGFloat desLabelH = height - labelY - border;
    self.teacherDesLabel.frame = CGRectMake(labelX, labelY, labelW, desLabelH);
}

- (void)updateContentWidhDesInfo:(NSDictionary *)desInfo {
    self.desTitleLabel.text = desInfo[kDesTitle];
    
    MLUser *teacher = desInfo[kDesTeacher];
    NSURL *iconURL = [NSURL URLWithString:[teacher objectForKey:@"iconUrl"]];
    [self.teacherIconView sd_setImageWithURL:iconURL placeholderImage:ImageNamed(@"ic_comment_head")];
    self.teacherNameLabel.text = teacher.username;
    
    self.teacherDesLabel.text = desInfo[kDesContent];
}

+ (CGFloat)cellHeightForTeacherInfo:(NSDictionary *)teacherInfo {
    NSString *desContent = teacherInfo[kDesContent];
    CGFloat txtW = CGRectGetWidth([UIScreen mainScreen].bounds) - 15 * 2 - 41 - 22;
    CGRect rect = [desContent boundingRectWithSize:CGSizeMake(txtW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil];
    
    return rect.size.height + 15 * 2 + 10 + 41 + 3 + 21;
}

@end
