//
//  MECourseGroupCell.h
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kInfoImgURL;
extern NSString * const kInfoCourseName;
extern NSString * const kInfoSubTitle;
extern NSString * const kInfoCourseCount;

@interface MECourseGroupCell : UITableViewCell
@property (nonatomic, copy) dispatch_block_t addCourseBlock;

- (void)updateContentWithInfo:(NSDictionary *)info;

@end
