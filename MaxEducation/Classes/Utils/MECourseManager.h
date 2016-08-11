//
//  MECourseManager.h
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MECourseManager : NSObject

+ (id)sharedManager;

- (void)fetchCourseCategoryIfNeededCompleteHandler:(void(^)(NSArray *cateObjs, NSError *error))completeHandler;

- (void)fetchHotCourseIfNeededCompleteHandler:(void(^)(NSArray *courseGroups, NSError *error))completeHandler;

- (void)fetchMyUploadedCourseIfNeededCompletedHandle:(void(^)(NSArray *uploadedObjs, NSError *error))completeHandler;

- (void)fetchMyUploadedCourseGroupCompletedHandler:(void(^)(NSArray *courseGroups, NSError *error))completeHandler;

@end
