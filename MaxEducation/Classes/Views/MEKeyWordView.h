//
//  MEKeyWordView.h
//  MaxEducation
//
//  Created by luomeng on 16/6/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEKeyWordViewProtocol <NSObject>
- (void)didTappedKeyWord:(NSString *)keyWord;
@end

@interface MEKeyWordView : UIView
@property (nonatomic, weak) id<MEKeyWordViewProtocol> delegate;
- (id)initWithFrame:(CGRect)frame keyWords:(NSArray *)keyWords;
@end
