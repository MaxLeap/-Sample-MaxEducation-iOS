//
//  MEWriteCommentVC.h
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEWriteCommentProtocol <NSObject>
- (void)didPublishedComment;
@end

@interface MEWriteCommentVC : UIViewController
@property (nonatomic, weak) id<MEWriteCommentProtocol> delegate;
@property (nonatomic, strong) MLObject *courseGroupObj;
@end
