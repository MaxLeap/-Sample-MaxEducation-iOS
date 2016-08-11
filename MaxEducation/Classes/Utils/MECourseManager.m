//
//  MECourseManager.m
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MECourseManager.h"

@interface MECourseManager ()
@property (nonatomic, strong) NSArray *courseCates;
@property (nonatomic, strong) NSArray *hotCourseGroups;
@end

@implementation MECourseManager

+ (id)sharedManager {
    static MECourseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MECourseManager alloc] init];
    });
    return manager;
}

- (void)fetchCourseCategoryIfNeededCompleteHandler:(void(^)(NSArray *cateObjs, NSError *error))completeHandler {
    if (self.courseCates.count) {
        if (completeHandler) {
            completeHandler(self.courseCates, nil);
        }
        return;
    }
    
    // fetch course cates
    MLQuery *cateQuery = [MLQuery queryWithClassName:@"MECourseCategory"];
    [cateQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            if (completeHandler) {
                completeHandler(nil, error);
            }
        } else {
            self.courseCates = objects;
            if (completeHandler) {
                completeHandler(objects, nil);
            }
        }
    }];
}

- (void)fetchHotCourseIfNeededCompleteHandler:(void(^)(NSArray *courseGroups, NSError *error))completeHandler {
//    if (self.hotCourseGroups.count) {
//        if (completeHandler) {
//            completeHandler(self.hotCourseGroups, nil);
//        }
//        return;
//    }
    
    MLQuery *courseGroupQuery = [MLQuery queryWithClassName:@"MECourseGroup"];
    [courseGroupQuery orderByDescending:@"learnedCount"];
    [courseGroupQuery includeKey:@"publisher"];
    courseGroupQuery.limit = 8;
    [courseGroupQuery orderByDescending:@"createdAt"];
    [courseGroupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            if (completeHandler) {
                completeHandler(nil, error);
            }
        } else {
            self.hotCourseGroups = objects;
            if (completeHandler) {
                completeHandler(objects, nil);
            }
        }
    }];
}

- (void)fetchMyUploadedCourseIfNeededCompletedHandle:(void(^)(NSArray *uploadedObjs, NSError *error))completeHandler {
    if (![MEMLUserHelper hasLogin]) {
        if (completeHandler) {
            completeHandler(nil, [NSError errorWithDomain:@"login needed" code:9870 userInfo:nil]);
        }
        return;
    }
    
//    if (self.myUploadedCourses.count) {
//        if (completeHandler) {
//            completeHandler(self.myUploadedCourses, nil);
//        }
//        return;
//    }
    
    // fetch my uploaded course
    MLQuery *courseQuery = [MLQuery queryWithClassName:@"MECourse"];
    [courseQuery whereKey:@"uploadUserID" equalTo:[MLUser currentUser].objectId];
    [courseQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            if (completeHandler) {
                completeHandler(nil, error);
            }
        } else {
//            self.myUploadedCourses = objects;
            if (completeHandler) {
                completeHandler(objects, nil);
            }
        }
    }];
}

- (void)fetchMyUploadedCourseGroupCompletedHandler:(void(^)(NSArray *courseGroups, NSError *error))completeHandler {
    if (![MEMLUserHelper hasLogin]) {
        if (completeHandler) {
            completeHandler(nil, [NSError errorWithDomain:@"login needed" code:9870 userInfo:nil]);
        }
        return;
    }
    
    // fetch my uploaded course
    MLQuery *courseQuery = [MLQuery queryWithClassName:@"MECourseGroup"];
    [courseQuery includeKey:@"publisher"];
    [courseQuery orderByDescending:@"createdAt"];
    [courseQuery whereKey:@"uploadUserId" equalTo:[MLUser currentUser].objectId];
    [courseQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            if (completeHandler) {
                completeHandler(nil, error);
            }
        } else {
            //            self.myUploadedCourses = objects;
            if (completeHandler) {
                completeHandler(objects, nil);
            }
        }
    }];
}

@end
