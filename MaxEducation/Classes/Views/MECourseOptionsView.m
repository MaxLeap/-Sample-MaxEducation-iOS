//
//  MECourseOptionsView.m
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MECourseOptionsView.h"

static CGFloat const kRowHeight = 47.0;
static CGFloat const kHeaderHeight = 60.0f;

@interface MECourseOptionsView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *cateOptions;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tapBackView;
@end

@implementation MECourseOptionsView

- (id)initWithFrame:(CGRect)frame cateOptions:(NSArray *)options {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.5);
        _cateOptions = options;
    
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    [self addSubview:self.tableView];
    
    self.tapBackView = [[UIView alloc] init];
    [self addSubview:self.tapBackView];
    
    UITapGestureRecognizer *tapBackGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGestureAction:)];
    [self.tapBackView addGestureRecognizer:tapBackGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat tableH = _cateOptions.count * kRowHeight + kHeaderHeight;
    CGFloat tableY = height - tableH;
    
    self.tapBackView.frame = CGRectMake(0, 0, width, tableY);
    
    self.tableView.frame = CGRectMake(0, height, width, tableH);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:5 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        self.tableView.frame = CGRectMake(0, tableY, width, tableH);
    } completion:nil];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cateOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MLObject *cateObj = _cateOptions[indexPath.row];
    cell.textLabel.text = cateObj[@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLObject *cateObj = _cateOptions[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectedCourseCategory:)]) {
        [self.delegate didSelectedCourseCategory:cateObj];
    }
    
    [self removeSelfFromSuperView];
}

#pragma mark - actions
- (void)xButtonAction:(UIButton *)sender {
    [self removeSelfFromSuperView];
}

- (void)tapBackGestureAction:(UITapGestureRecognizer *)gesture {
    [self removeSelfFromSuperView];
}

- (void)removeSelfFromSuperView {
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat height = CGRectGetHeight(self.bounds);
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat tableH = CGRectGetHeight(self.tableView.bounds);
        self.tableView.frame = CGRectMake(0, height, width, tableH);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - getters & setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];;
        _tableView.rowHeight = kRowHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.tableHeaderView = [self tableHeaderView];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (UIView *)tableHeaderView {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kHeaderHeight)];
    [headerView addBottomBorderWithColor:UIColorFromRGBA(156, 157, 159, 0.5) width:1];

    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, kHeaderHeight / 2)];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.text = @"课程分类";
    titleL.textColor = UIColorFromRGBA(156, 157, 159, 1);
    [headerView addSubview:titleL];
    
    CGFloat btnW = 30;
    CGFloat btnY = (kHeaderHeight / 2 - btnW ) / 2;
    CGFloat btnX = width - btnW - 15;
    UIButton *xBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnW)];
    [xBtn setImage:ImageNamed(@"icn_cancel") forState:UIControlStateNormal];
    [xBtn addTarget:self action:@selector(xButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:xBtn];
    
    UILabel *optionL = [[UILabel alloc] initWithFrame:CGRectMake(15, kHeaderHeight / 2, 60, kHeaderHeight / 2)];
    optionL.textColor = UIColorFromRGBA(42, 176, 149, 1);
    optionL.text = @"请选择";
    optionL.textAlignment = NSTextAlignmentCenter;
    [optionL addBottomBorderWithColor:UIColorFromRGBA(42, 176, 149, 2) width:1];
    [headerView addSubview:optionL];
    
    return headerView;
}

@end
