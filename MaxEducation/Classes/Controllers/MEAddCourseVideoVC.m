//
//  MEAddCourseVideoVC.m
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEAddCourseVideoVC.h"

@interface MEAddCourseVideoVC () < UIImagePickerControllerDelegate,
 UINavigationControllerDelegate
>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *topContainer;
@property (nonatomic, strong) UIView *tapViewContainer;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, copy) NSString *selectedMoviePath;

@property (nonatomic, strong) UILabel *videoPathLabel;
@property (nonatomic, assign) BOOL hasShowBefore;
@end

@implementation MEAddCourseVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hasShowBefore) {
        _hasShowBefore = YES;
        [self.textField becomeFirstResponder];
    }
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"添加章节";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sureAction:)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.topContainer];
    
    [self.view addSubview:self.tapViewContainer];
    self.tapViewContainer.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addVideoAction:)];
    [self.tapViewContainer addGestureRecognizer:tapGesture];
}

#pragma mark actions
- (void)sureAction:(UIBarButtonItem *)item {
    
    NSString *videoTitle = self.textField.text;
    if (videoTitle.length <= 0 || self.selectedMoviePath.length <= 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请输入内容" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectedVideoTitle:atPath:)]) {
        [self.delegate didSelectedVideoTitle:videoTitle atPath:self.selectedMoviePath];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addVideoAction:(UITapGestureRecognizer *)gesture {
    [self.textField resignFirstResponder];
    NSLog(@"add video action");
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"设备不支持"];
    }
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl = (NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        self.selectedMoviePath = moviePath;
        
        self.videoPathLabel.text = [NSString stringWithFormat:@"已选视频:%@", moviePath];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setter & getters
- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    return _imagePickerController;
}

- (UIView *)topContainer {
    if (!_topContainer) {
        _topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 50)];
        _topContainer.backgroundColor = [UIColor whiteColor];
        [_topContainer addSubview:self.textField];
    }
    return _topContainer;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.view.bounds) - 20, 50)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = [self leftLabel];
    }
    return _textField;
}

- (UIView *)tapViewContainer {
    if (!_tapViewContainer) {
        CGFloat containerX = 10;
        CGFloat containerY = CGRectGetMaxY(self.topContainer.frame) + 15;
        CGFloat containerW = CGRectGetWidth(self.view.frame) - containerX * 2;
        CGFloat containerH = 215;
        _tapViewContainer = [[UIView alloc] initWithFrame:CGRectMake(containerX, containerY, containerW, containerH)];
        _tapViewContainer.backgroundColor = [UIColor whiteColor];
        
        CGFloat addImageW = 46;
        CGFloat addImageX = (containerW - addImageW) / 2;
        CGFloat addImageY = containerH / 2 - 20;
        CGRect imgFrame = CGRectMake(addImageX, addImageY, addImageW, addImageW);
        [_tapViewContainer addSubview:[self addImageViewWithFrame:imgFrame]];
        
        CGFloat labelY = addImageY + addImageW + 5;
        CGFloat labelH = 70;
        CGRect labelFrame = CGRectMake(0, labelY, containerW, labelH);
        self.videoPathLabel = [self addVideoLabelWithFrame:labelFrame];
        [_tapViewContainer addSubview:self.videoPathLabel];
    }
    return _tapViewContainer;
}

- (UIImageView *)addImageViewWithFrame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = ImageNamed(@"icn_addmovie");
    return imageView;
}

- (UILabel *)addVideoLabelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = @"添加视频";
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

- (UILabel *)leftLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 50)];
    label.text = @"章节名称:";
    return label;
}

@end
