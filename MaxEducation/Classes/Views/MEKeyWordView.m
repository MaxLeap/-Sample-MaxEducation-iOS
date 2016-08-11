//
//  MEKeyWordView.m
//  MaxEducation
//
//  Created by luomeng on 16/6/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEKeyWordView.h"

@interface MEKeyWordView ()
@property (nonatomic, strong) NSArray *keywords;
@end

@implementation MEKeyWordView

- (id)initWithFrame:(CGRect)frame keyWords:(NSArray *)keyWords {
    if (self = [super initWithFrame:frame]) {
        _keywords = keyWords;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    CGFloat startX = 15;
    CGFloat borderX = 9;
    CGFloat borderY = 15;
    CGFloat btnX = startX;
    CGFloat btnY = borderY;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    for (NSString *keyword in _keywords) {
        NSDictionary *titleAttri = [self btnTitleAttributes];
        CGRect rect = [keyword boundingRectWithSize:CGSizeMake(MAXFLOAT, 14) options:NSStringDrawingUsesFontLeading attributes:titleAttri context:nil];
        CGFloat btnW = rect.size.width + 20;
        CGFloat btnH = 25;
        if (btnX + btnW > screenW - startX) {
            btnX = startX;
            btnY = btnY + btnH + borderY;
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        [btn setTitle:keyword forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.layer.cornerRadius = btnH / 2;
        btn.clipsToBounds = YES;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = UIColorFromRGBA(155, 156, 158, 1).CGColor;
        [btn setTitleColor:UIColorFromRGBA(155, 156, 158, 1) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(keywordBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        btnX = btnX + btnW + borderX;
    }
}
                        
- (NSDictionary *)btnTitleAttributes {
    return @{
             NSFontAttributeName : [UIFont systemFontOfSize:12],
             NSForegroundColorAttributeName : UIColorFromRGBA(155, 156, 158, 1)
             };
}

- (void)keywordBtnAction:(UIButton *)sender {
    NSString *keyword = sender.titleLabel.text;
    NSLog(@"tapped keyword = %@", keyword);
    if ([self.delegate respondsToSelector:@selector(didTappedKeyWord:)]) {
        [self.delegate didTappedKeyWord:keyword];
    }
}

@end
