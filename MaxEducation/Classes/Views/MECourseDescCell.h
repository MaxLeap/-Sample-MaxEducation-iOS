//
//  MECourseDescCell.h
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kDesTitle;
extern NSString * const kDesContent;
extern NSString * const kDesTeacher;

@interface MECourseDescCell : UITableViewCell
- (void)updateContentWithDescInfo:(NSDictionary *)desInfo;
+ (CGFloat)cellHeightForDesContent:(NSString *)desContent;
@end

@interface MEDescTeacherCell : UITableViewCell
- (void)updateContentWidhDesInfo:(NSDictionary *)desInfo;
+ (CGFloat)cellHeightForTeacherInfo:(NSDictionary *)teacherInfo;
@end
