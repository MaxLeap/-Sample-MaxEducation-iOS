//
//  MEHeaderView.m
//  MaxEducation
//
//  Created by luomeng on 16/6/21.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEHeaderView.h"

@interface MEHeaderView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *contents;
@end

@implementation MEHeaderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    self.scrollView.frame = self.bounds;
    
    for (NSInteger i = 0; i < _contents.count; i ++) {
        NSInteger tag = i + 1000;
        UIImageView *imgView = [self.scrollView viewWithTag:tag];
        CGFloat imgX = width * i;
        imgView.frame = CGRectMake(imgX, 0, width, height);
    }
    
    self.scrollView.contentOffset = CGPointMake(width * self.pageControl.currentPage, 0);
    
    self.pageControl.frame = CGRectMake(0, height - 40, width, 40);
}

- (void)shouldScollWithOffsetX:(CGFloat)offsetX {
    CGFloat offsetNow = self.scrollView.contentOffset.x;
    
    self.scrollView.contentOffset = CGPointMake(offsetNow - offsetX, 0);
}

- (void)shouldEndScollWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    CGFloat offsetX = self.scrollView.contentOffset.x;
    CGFloat numberOfPages = self.pageControl.numberOfPages;
    CGRect rectToShow;
    if (offsetX <= 0) {
        rectToShow = CGRectMake(0, 0, width, height);
    } else if (offsetX >= width * (numberOfPages - 1)) {
        rectToShow = CGRectMake(width * (numberOfPages - 1), 0, width, height);
    } else {
        NSInteger currentPage = self.pageControl.currentPage;
        if (velocity.x < -300) {
            CGFloat newPage = currentPage + 1;
            self.pageControl.currentPage = newPage;
            rectToShow = CGRectMake(width * newPage, 0, width, height);
        } else if (velocity.x > 300) {
            CGFloat newPage = currentPage - 1;
            self.pageControl.currentPage = newPage;
            rectToShow = CGRectMake(width * newPage, 0, width, height);
        } else {
            rectToShow = CGRectMake(width * currentPage, 0, width, height);
        }
    }
    [self.scrollView scrollRectToVisible:rectToShow animated:YES];
}

- (void)updateContentWithCourses:(NSArray *)groups {
    _contents = groups;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    self.scrollView.contentSize = CGSizeMake(width * groups.count, height);
    for (NSInteger i = 0; i < groups.count; i ++) {
        MLObject *courseGroup = groups[i];
        
        CGFloat imgX = width * i;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, 0, width, height)];
        imgView.tag = 1000 + i;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        NSURL *coverImgURL = [NSURL URLWithString:courseGroup[@"coverImgURL"]];
        [imgView sd_setImageWithURL:coverImgURL placeholderImage:ImageNamed(@"default")];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:tapGesture];
        
        [self.scrollView addSubview:imgView];
    }
    
    self.pageControl.numberOfPages = groups.count;
    self.pageControl.currentPage = 0;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    CGFloat offsetX = self.scrollView.contentOffset.x;
    NSInteger page = (NSInteger)(offsetX / CGRectGetWidth(self.bounds));
    if ([self.delegate respondsToSelector:@selector(didTappedCourseGroup:)]) {
        if (page >= 0 && page < _contents.count) {
            MLObject *courseGroup = _contents[page];
            [self.delegate didTappedCourseGroup:courseGroup];
        }
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger page = (NSInteger)(offsetX / CGRectGetWidth(self.bounds) + 0.5);
    self.pageControl.currentPage = page;
}

#pragma mark - private method
- (void)initSubViews {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.pageIndicatorTintColor = UIColorFromRGBA(152, 107, 49, 1);
    [self addSubview:self.pageControl];
}

@end
