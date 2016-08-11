//
//  MEHeaderView.h
//  MaxEducation
//
//  Created by luomeng on 16/6/21.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEHeaderViewProtocol <NSObject>
- (void)didTappedCourseGroup:(MLObject *)courseGroup;
@end

@interface MEHeaderView : UIView
@property (nonatomic, weak) id<MEHeaderViewProtocol> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)updateContentWithCourses:(NSArray *)groups;

- (void)shouldScollWithOffsetX:(CGFloat)offsetX;

- (void)shouldEndScollWithVelocity:(CGPoint)velocity;
@end
