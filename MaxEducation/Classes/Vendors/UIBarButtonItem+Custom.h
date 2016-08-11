//
//  UIBarButtonItem+Custom.h
//  iKeyboard
//
//  Created by XiaJun on 15/4/3.
//  Copyright (c) 2015年 iLegendSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Custom)
+ (UIBarButtonItem *)barButtonItemWithNormalImagenName:(NSString *)normalImageName
                                  highlightedImageName:(NSString *)highlightedImageName
                                                target:(id)taget
                                                action:(SEL)action;

+ (UIBarButtonItem *)barButtonItemWithNormalImagenName:(NSString *)normalImageName
                                     selectedImageName:(NSString *)selectedImageName
                                                target:(id)taget
                                                action:(SEL)action;

@end
