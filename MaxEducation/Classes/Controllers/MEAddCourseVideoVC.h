//
//  MEAddCourseVideoVC.h
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEAddVideoProtocol <NSObject>
- (void)didSelectedVideoTitle:(NSString *)chapterName atPath:(NSString *)videoPath;
@end

@interface MEAddCourseVideoVC : UIViewController
@property (nonatomic, weak) id<MEAddVideoProtocol> delegate;
@end
