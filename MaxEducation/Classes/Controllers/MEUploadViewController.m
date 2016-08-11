//
//  MEUploadViewController.m
//  MaxEducation
//
//  Created by luomeng on 16/6/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEUploadViewController.h"
#import "MEUploadCell.h"
#import "MEAddCourseVideoVC.h"
#import "MECourseOptionsView.h"
#import "MECourseManager.h"
#import "UIImage+Resize.h"

static NSString * const kUploadCellID = @"uploadCell";

@interface MEUploadViewController () <UITableViewDelegate,
 UITableViewDataSource,
 UIImagePickerControllerDelegate,
 UINavigationControllerDelegate,
 MECourseOptionsProtocol,
 MEAddVideoProtocol,
 MEUploadCellProtocol
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIView *edittingView;

// upload meta
@property (nonatomic, strong) UIImage *courseImage;
@property (nonatomic, strong) NSString *uploadVideoPath;
@property (nonatomic, strong) MLObject *selectedCateObj;
@property (nonatomic, copy) NSString *chapterName;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *courseName;
@property (nonatomic, copy) NSString *suitPeople;
@property (nonatomic, copy) NSString *courseDes;
@property (nonatomic, copy) NSString *teacherDes;
// 上传成功后的参数
@property (nonatomic, copy) NSString *courseImgURL;
@property (nonatomic, copy) NSString *videoURL;
@end

@implementation MEUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.courseName = self.courseGroup[@"groupName"] ?  : @"";
    self.suitPeople = self.courseGroup[@"suitPeople"] ? : @"";
    self.courseDes = self.courseGroup[@"courseDes"] ? : @"";
    self.teacherDes = self.courseGroup[@"teacherDes"] ? : @"";
    NSString *coverImgURL = self.courseGroup[@"coverImgURL"] ? : @"";
    self.dataSource = @[
        @{@"title": @"课程名称:", @"placeHolder":@"请输入课程名，最多20字", @"content": self.courseName},
        @{@"title": @"课程分类:", @"placeHolder":@"", @"content": @""},
        @{@"title": @"课程图片:", @"placeHolder":@"", @"content": coverImgURL},
        @{@"title": @"适用人群:", @"placeHolder":@"请输入适用人群，最多20字", @"content": self.suitPeople},
        @{@"title": @"课程概况:", @"placeHolder":@"请输入课程概况，最多100字", @"content": self.courseDes},
        @{@"title": @"讲师介绍:", @"placeHolder":@"请输入讲师介绍，最多100字", @"content": self.teacherDes},
        @{@"title": @"课程章节:", @"placeHolder":@"", @"content": @""},
                        ];
    
    [self addObservers];
    
    [self buildUI];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"上传课程";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publishAction:)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MEUploadCell *cell = [tableView dequeueReusableCellWithIdentifier:kUploadCellID forIndexPath:indexPath];
    cell.delegate = self;
    NSDictionary *data = self.dataSource[indexPath.row];
    
    UploadCellType type;
    NSString *content = data[@"content"];
    NSInteger limitCount = 100;
    if (indexPath.row == 1 || indexPath.row == 6) {
        type = UploadCellTypeLabel;
        if (indexPath.row == 6) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (self.chapterName.length) {
                content = self.chapterName;
            }
        } else {
            if (self.selectedCateObj) {
                content = self.selectedCateObj[@"name"];
            } else {
                [self fetchCourseCateInfoInbackground];
            }
        }
    } else if (indexPath.row == 2) {
        type = UploadCellTypeImageView;
        MEUploadViewController *__weak wself = self;
        cell.addImageBlock = ^() {
            [wself addCourseImageAction];
        };
        
        content = _courseImage ? @"" : self.courseGroup[@"coverImgURL"];
    } else {
        type = UploadCellTypeTextField;
        
        if (indexPath.row == 0) {
            content = _courseName ? _courseName : content;
            limitCount = 20;
        } else if (indexPath.row == 3) {
            content = _suitPeople ? _suitPeople : content;
            limitCount = 20;
        } else if (indexPath.row == 4) {
            type = UploadCellTypeTextView;
            content = _courseDes ? _courseDes : content;
            limitCount = 100;
        } else if (indexPath.row == 5) {
            type = UploadCellTypeTextView;
            content = _teacherDes ? _teacherDes : content;
            limitCount = 100;
        }
    }
    
    [cell configCellWithTitle:data[@"title"] content:content placeHolder:data[@"placeHolder"] forCellType:type limitCount:limitCount];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 5) {
        return 90;
    } else if (indexPath.row == 1 || indexPath.row == 6) {
        return 60;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        [self.edittingView resignFirstResponder];
        [self showCourseCateOptions];
    } else if (indexPath.row == 6) {
        [self.edittingView resignFirstResponder];
        [self toAddCourseVideo];
    }
}


#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.courseImage = [image resizedImage:CGSizeMake(960, 640) interpolationQuality:kCGInterpolationDefault];
        
        NSIndexPath *imgCellIndex = [NSIndexPath indexPathForRow:2 inSection:0];
        MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:imgCellIndex];
        [cell updateCourseImage:image];
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Custom delegate
- (void)beginEditingTextField:(UIView *)textField {
    self.edittingView = textField;
}

- (void)didEndEditingText:(MEUploadCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    switch (row) {
        case 0: {
            MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            _courseName = [cell textFieldInputContent];
            break;
        }
        case 1: {}
        case 2: {
            break;
        }
        case 3: {
            MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            _suitPeople = [cell textFieldInputContent];
            break;
        }
        case 4: {
            MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            _courseDes = [cell textFieldInputContent];
            break;
        }
        case 5: {
            MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            _teacherDes = [cell textFieldInputContent];
            break;
        }
        case 6: {
            break;
        }
        default:
            break;
    }
}

- (void)didSelectedCourseCategory:(MLObject *)cateObj {
    self.selectedCateObj = cateObj;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateLabelContent:cateObj[@"name"]];
}

- (void)didSelectedVideoTitle:(NSString *)chapterName atPath:(NSString *)videoPath {
    self.chapterName = chapterName;
    self.videoPath = videoPath;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:6 inSection:0];
    MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateLabelContent:chapterName];
}

#pragma mark - private method
- (void)fetchCourseCateInfoInbackground {
    if (self.courseGroup) {
        NSString *cateId = self.courseGroup[@"belongToCategoryID"];
        MLQuery *cateQuery = [MLQuery queryWithClassName:@"MECourseCategory"];
        [cateQuery whereKey:@"objectId" equalTo:cateId];
        [cateQuery getFirstObjectInBackgroundWithBlock:^(MLObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                [self didSelectedCourseCategory:object];
            }
        }];
    }
}

- (void)addCourseImageAction {
    [self presentViewController:self.actionController animated:YES completion:nil];
}

- (void)didUploadedCourseSuccess {
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidUploadCourseSuccessNotify object:nil];
}

- (void)showCourseCateOptions {
    
    [[MECourseManager sharedManager] fetchCourseCategoryIfNeededCompleteHandler:^(NSArray *cateObjs, NSError *error) {
        if (cateObjs.count) {
           dispatch_async(dispatch_get_main_queue(), ^{
               MECourseOptionsView *courseOptionsV = [[MECourseOptionsView alloc] initWithFrame:[UIScreen mainScreen].bounds cateOptions:cateObjs];
                   courseOptionsV.delegate = self;
               [self.navigationController.view addSubview:courseOptionsV];
           });
        } else {
            [SVProgressHUD showErrorWithStatus:@"出错了，请稍后再试"];
        }
    }];
}

- (void)toAddCourseVideo {
    MEAddCourseVideoVC *addCourseVideoVC = [[MEAddCourseVideoVC alloc] init];
    addCourseVideoVC.delegate = self;
    [self.navigationController pushViewController:addCourseVideoVC animated:YES];
}

- (void)publishAction:(UIBarButtonItem *)item {
    
    NSString *courseName, *suitPeople, *courseDes, *teacherDes;
    
    for (NSInteger i = 0; i < 7; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        switch (i) {
            case 0: {
                MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                courseName = [cell textFieldInputContent];
                courseName = _courseName.length ? _courseName : courseName;
                break;
            }
            case 1: {}
            case 2: {
                break;
            }
            case 3: {
                MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                suitPeople = [cell textFieldInputContent];
                suitPeople = _suitPeople.length ? _suitPeople : suitPeople;
                break;
            }
            case 4: {
                MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                courseDes = [cell textFieldInputContent];
                courseDes = _courseDes.length ? _courseDes : courseDes;
                break;
            }
            case 5: {
                MEUploadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                teacherDes = [cell textFieldInputContent];
                teacherDes = _teacherDes.length ? _teacherDes : teacherDes;
                break;
            }
            case 6: {
                break;
            }
            default:
                break;
        }
    }
    
    if (courseName.length <=0 || suitPeople.length <= 0 || courseDes.length <=0 || teacherDes.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入完整内容" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSDictionary *courseInfo = @{@"suitPeople": suitPeople,
                                 @"courseDes" : courseDes,
                                 @"teacherDes": teacherDes,
                                 @"groupName" : courseName};
    if (self.courseGroup) {
        [self publishCourseToExistCourseGroup:courseInfo];
    } else {
        [self publishNewCourseWithCourseInfo:courseInfo];
    }
}

- (void)publishCourseToExistCourseGroup:(NSDictionary *)courseInfo {
    // 向当前group 中添加一个课程
    if (self.chapterName.length <= 0 || self.videoPath.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请先添加章节内容"];
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    if (self.courseImage) {
        [SVProgressHUD showWithStatus:@"上传课程图片..."];
        [self uploadImageCompleteHandler:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self uploadVideoAndSaveToExistGroupWithCourse:courseInfo];
            } else {
                [SVProgressHUD showErrorWithStatus:@"上传课程图片失败!"];
            }
        }];
    } else {
        [self uploadVideoAndSaveToExistGroupWithCourse:courseInfo];
    }
}

- (void)uploadVideoAndSaveToExistGroupWithCourse:(NSDictionary *)courseInfo {
    [SVProgressHUD showWithStatus:@"上传视频..."];
    [self uploadVideoCompleteHandler:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSString *groupID = self.courseGroup.objectId;
            NSDictionary *chapterInfo = @{@"courseName": self.chapterName};
            [SVProgressHUD showWithStatus:@"保存课程"];
            [self createCourseObjAndSaveInGroup:groupID courseInfo:chapterInfo completeHandler:^(BOOL succeeded) {
                if (succeeded) {
                    [SVProgressHUD showWithStatus:@"更新课程信息"];
                    [self updateCurrentCourseGroupObjWithGroupInfo:courseInfo completeHandler:^(BOOL success, NSError *error) {
                        if (success) {
                            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                            [self performSelector:@selector(didUploadedCourseSuccess) withObject:nil afterDelay:0.5];
                        } else {
                            [SVProgressHUD showErrorWithStatus:@"更新课程信息失败"];
                        }
                    }];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"上传失败"];
                }
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"上传视频失败"];
        }
    }];
}

- (void)publishNewCourseWithCourseInfo:(NSDictionary *)courseInfo {
    if (self.chapterName.length <= 0 || self.videoPath.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请先添加章节内容"];
        return;
    }
    
    if (!self.selectedCateObj) {
        [SVProgressHUD showErrorWithStatus:@"请选择课程分类"];
        return;
    }
    
    if (!self.courseImage) {
        [SVProgressHUD showErrorWithStatus:@"没有选择课程图片"];
        return;
    }
    
    // 上传图片 --> 上传视频 -->
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"上传课程图片..."];
    [self uploadImageCompleteHandler:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [SVProgressHUD showWithStatus:@"上传视频..."];
            [self uploadVideoCompleteHandler:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // 先创建Group --> 然后添加课程
                    [SVProgressHUD showWithStatus:@"保存课程"];
                    [self createCourseGroupObjWithGroupInfo:courseInfo CompleteHandler:^(BOOL succeeded, NSString *groupID) {
                        if (succeeded) {
                            NSDictionary *courseInfo = @{@"courseName": self.chapterName};
                            [self createCourseObjAndSaveInGroup:groupID courseInfo:courseInfo completeHandler:^(BOOL succeeded) {
                                if (succeeded) {
                                    [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                                    [self performSelector:@selector(didUploadedCourseSuccess) withObject:nil afterDelay:0.5];
                                } else {
                                    [SVProgressHUD showErrorWithStatus:@"上传失败"];
                                }
                            }];
                        } else {
                            [SVProgressHUD showErrorWithStatus:@"上传失败"];
                        }
                    }];
                    
                } else {
                    [SVProgressHUD showErrorWithStatus:@"上传课程视频出错."];
                }
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"上传课程图片出错了!"];
        }
    }];
}

- (void)createCourseGroupObjWithGroupInfo:(NSDictionary *)groupInfo CompleteHandler:(void(^)(BOOL succeeded, NSString *groupID))completeHandler {
    MLObject *groupObj = [MLObject objectWithClassName:@"MECourseGroup"];
    groupObj[@"belongToCategoryID"] = self.selectedCateObj.objectId;
    groupObj[@"courseCount"] = @(1);
    groupObj[@"uploadUserId"] = [MLUser currentUser].objectId;
    groupObj[@"groupName"] = groupInfo[@"groupName"];
    groupObj[@"suitPeople"] = groupInfo[@"suitPeople"];
    groupObj[@"courseDes"] = groupInfo[@"courseDes"];
    groupObj[@"teacherDes"] = groupInfo[@"teacherDes"];
    groupObj[@"coverImgURL"] = self.courseImgURL;
    groupObj[@"publisher"] = [MLUser currentUser];
    groupObj[@"learnedCount"] = @(0);
    [groupObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            if (completeHandler) {
                completeHandler(YES, groupObj.objectId);
            }
        } else {
            if (completeHandler) {
                completeHandler(NO, nil);
            }
        }
    }];
}

- (void)updateCurrentCourseGroupObjWithGroupInfo:(NSDictionary *)groupInfo completeHandler:(void(^)(BOOL success, NSError *error))completeHandler {
    NSInteger courseCount = [self.courseGroup[@"courseCount"] integerValue];
    self.courseGroup[@"courseCount"] = @(++courseCount);
    self.courseGroup[@"groupName"] = groupInfo[@"groupName"];
    self.courseGroup[@"suitPeople"] = groupInfo[@"suitPeople"];
    self.courseGroup[@"courseDes"] = groupInfo[@"courseDes"];
    self.courseGroup[@"teacherDes"] = groupInfo[@"teacherDes"];
    if (self.courseImgURL) {
        self.courseGroup[@"coverImgURL"] = self.courseImgURL;
    }
    
    [self.courseGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (completeHandler) {
            completeHandler(succeeded, error);
        }
    }];
}

- (void)createCourseObjAndSaveInGroup:(NSString *)groupId courseInfo:(NSDictionary *)courseInfo completeHandler:(void(^)(BOOL succeeded))completeHandler {
    MLObject *courseObj = [MLObject objectWithClassName:@"MECourse"];
    courseObj[@"belongToGroupID"] = groupId;
    courseObj[@"uploadUserID"] = [MLUser currentUser].objectId;
    courseObj[@"courseName"] = courseInfo[@"courseName"];
    courseObj[@"videoURL"] = self.videoURL;
    courseObj[@"viewCount"] = @(0);
    [courseObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (completeHandler) {
            completeHandler(succeeded);
        }
    }];
}

- (void)uploadImageCompleteHandler:(void(^)(BOOL succeeded, NSError *error))completeHandler {
    NSData *data = UIImageJPEGRepresentation(self.courseImage, 0.5);
    MLFile *file = [MLFile fileWithName:@"courseImg.png" data:data];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.courseImgURL = file.url;
            if (completeHandler) {
                completeHandler(YES, nil);
            }
        } else {
            if (completeHandler) {
                completeHandler(NO, error);
            }
        }
    }];
}

- (void)uploadVideoCompleteHandler:(void(^)(BOOL succeeded, NSError *error))completeHandler {
    NSString *fileName = [self.videoPath lastPathComponent];
    MLFile *file = [MLFile fileWithName:fileName contentsAtPath:self.videoPath];
    NSLog(@"file url = %@", file.url);
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"error = %@", error);
        NSLog(@"file url = %@", file.url);
        if (error) {
            if (completeHandler) {
                completeHandler(NO, error);
            }
        } else {
            self.videoURL = file.url;
            if (completeHandler) {
                completeHandler(YES, nil);
            }
        }
    } progressBlock:^(int percentDone) {
        NSLog(@"percentDone = %d", percentDone);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:(float)percentDone / 100 status:@"上传视频..."];
        });
    }];
}

#pragma mark - keyboard event
- (void)keyboardWillAppear:(NSNotification *)notify {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notify.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    NSNumber *duration = [notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notify.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // modify constraints
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.tableView.frame = CGRectMake(0, 0, width, height - CGRectGetHeight(keyboardBounds));
    
    // commit animations
    [UIView commitAnimations];
}

- (void)keyboardWillDisappear:(NSNotification *)notify {
    NSNumber *duration = [notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notify.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];

    self.tableView.frame = self.view.bounds;
    
    [UIView commitAnimations];
}

#pragma mark - setters & getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[MEUploadCell class] forCellReuseIdentifier:kUploadCellID];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIAlertController *)actionController {
    if (!_actionController) {
        _actionController = [UIAlertController alertControllerWithTitle:nil
             message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照"
             style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
                    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:self.imagePickerController animated:YES completion:nil];
                 }
        }];
        
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册中选择"
              style:UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
                   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                         self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                          [self presentViewController:self.imagePickerController animated:YES completion:nil];
                    }
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [_actionController addAction:takePhotoAction];
        [_actionController addAction:albumAction];
        [_actionController addAction:cancelAction];
    }
    return _actionController;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

@end



