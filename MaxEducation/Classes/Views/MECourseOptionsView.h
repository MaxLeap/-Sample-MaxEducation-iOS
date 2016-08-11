//
//  MECourseOptionsView.h
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MECourseOptionsProtocol <NSObject>
- (void)didSelectedCourseCategory:(MLObject *)cateObj;
@end

@interface MECourseOptionsView : UIView
@property (nonatomic, weak) id<MECourseOptionsProtocol> delegate;

- (id)initWithFrame:(CGRect)frame cateOptions:(NSArray *)options;

@end
