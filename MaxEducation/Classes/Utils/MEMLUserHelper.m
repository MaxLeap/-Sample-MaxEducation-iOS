//
//  MEMLUserHelper.m
//  MaxEducation
//
//  Created by luomeng on 16/6/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEMLUserHelper.h"

@implementation MEMLUserHelper

+ (BOOL)hasLogin {
    MLUser *currentUser = [MLUser currentUser];
    if (currentUser && ![MLAnonymousUtils isLinkedWithUser:currentUser]) {
        return YES;
    }
    return NO;
}

@end
