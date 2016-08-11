//
//  MECourseDetailViewController.h
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MECourseDetailViewController : UIViewController
@property (nonatomic, strong) MLObject *groupObj;
@end

@interface MEContentListCell : UITableViewCell
- (void)updateContentWithCourseName:(NSString *)courseName forIndexPath:(NSIndexPath *)indexPath;
@end

@interface MECommentCell : UITableViewCell
- (void)updateContentWithCommentObj:(MLObject *)commentObj;
@end
