//
//  MEPersonViewController.h
//  MaxEducation
//
//  Created by luomeng on 16/6/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kHistoryInfoCoverImage;
extern NSString * const kHistoryInfoTitle;
extern NSString * const kHistoryInfoDes;

@interface MEPersonViewController : UIViewController

@end


@interface MEHistoryCell : UITableViewCell
- (void)updateCellWithContentDic:(NSDictionary *)contentDic;
@end
