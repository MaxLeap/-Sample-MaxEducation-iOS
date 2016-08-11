//
//  MECourseDetailViewController.m
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MECourseDetailViewController.h"
#import "UIBarButtonItem+Custom.h"
#import <MaxSocialShare/MaxSocialShare.h>
#import "MEWriteCommentVC.h"
#import "MECourseDescCell.h"
#import <AVKit/AVKit.h>

static CGFloat const kTopContainerH = 260;
static CGFloat const kButtonCaontainerH = 50;

static NSString * const kContentListCell = @"contentListCell";
static NSString * const kDesCell = @"desCell";
static NSString * const kCommentCell = @"commentCell";
static NSString * const kDesTeacherCell = @"teacherCell";

@interface MECourseDetailViewController () <UITableViewDelegate,
 UITableViewDataSource,
 MEWriteCommentProtocol
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *topContainer;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIButton *lastSelectedBtn;
@property (nonatomic, strong) NSArray *desSegmentDataSource;
@property (nonatomic, strong) NSArray *coursesInGroup;
@property (nonatomic, strong) NSArray *commentsForGroup;

@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, assign) BOOL forceSelectIndex2;
@end

@implementation MECourseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.desSegmentDataSource = @[
            @{  kDesTitle : @"课程概况",
               kDesContent: self.groupObj[@"courseDes"]},
            @{  kDesTitle :@"适用人群",
                kDesContent: self.groupObj[@"suitPeople"]},
            @{  kDesTitle : @"讲师介绍",
                kDesTeacher: self.groupObj[@"publisher"],
                kDesContent: self.groupObj[@"teacherDes"]}
                                  ];
    
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.forceSelectIndex2) {
        [self segementButtonAction:self.commentBtn];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.forceSelectIndex2 = NO;
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"课程详情";
    
    UIBarButtonItem *addCommentItem = [UIBarButtonItem barButtonItemWithNormalImagenName:@"ic_addcomment" highlightedImageName:nil target:self action:@selector(addCommentAction:)];
    addCommentItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *shareItem = [UIBarButtonItem barButtonItemWithNormalImagenName:@"icn_share" highlightedImageName:nil target:self action:@selector(shareAction:)];
    shareItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItems = @[shareItem, addCommentItem];
    
    [self.view addSubview:self.topContainer];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isShowComment]) {
        return self.commentsForGroup.count;
    } else if ([self isShowContentList]) {
        return self.coursesInGroup.count;
    } else {
        return self.desSegmentDataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isShowComment]) {
        return 90;
    } else if ([self isShowContentList]) {
        return 60;
    } else {
        NSDictionary *desInfo = self.desSegmentDataSource[indexPath.row];
        if (indexPath.row <= 1) {
            NSString *desContent = desInfo[kDesContent];
            CGFloat height = [MECourseDescCell cellHeightForDesContent:desContent];
            return height;
        }
        
        CGFloat height = [MEDescTeacherCell cellHeightForTeacherInfo:desInfo];        
        return height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isShowComment]) {
        MECommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCell forIndexPath:indexPath];
        MLObject *commentObj = self.commentsForGroup[indexPath.row];
        [cell updateContentWithCommentObj:commentObj];
        return cell;
    } else if ([self isShowContentList]) {
        MEContentListCell *cell = [tableView dequeueReusableCellWithIdentifier:kContentListCell forIndexPath:indexPath];
        MLObject *courseObj = self.coursesInGroup[indexPath.row];
        [cell updateContentWithCourseName:courseObj[@"courseName"] forIndexPath:indexPath];
        return cell;
    } else {
        
        if (indexPath.row <= 1) {
            MECourseDescCell *cell = [tableView dequeueReusableCellWithIdentifier:kDesCell forIndexPath:indexPath];
            NSDictionary *desInfo = self.desSegmentDataSource[indexPath.row];
            [cell updateContentWithDescInfo:desInfo];
            return cell;
        }
        MEDescTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:kDesTeacherCell forIndexPath:indexPath];
        NSDictionary *teacherDes = self.desSegmentDataSource[indexPath.row];
        [cell updateContentWidhDesInfo:teacherDes];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isShowContentList]) {
        MLObject *courseObj = self.coursesInGroup[indexPath.row];
        [self logViewHistoryAndPlayCourse:courseObj];
    }
}

#pragma mark - custom protocol
- (void)didPublishedComment {
    self.forceSelectIndex2 = YES;
}

#pragma mark - private
- (BOOL)isShowCourseDes {
    return self.lastSelectedBtn.tag == 1000;
}

- (BOOL)isShowContentList {
    return self.lastSelectedBtn.tag == 1001;
}

- (BOOL)isShowComment {
    return self.lastSelectedBtn.tag == 1002;
}

- (void)logViewHistoryAndPlayCourse:(MLObject *)course {
    
    MLObject *viewHistroyObj = [MLObject objectWithClassName:@"MEViewHistory"];
    viewHistroyObj[@"viewerID"] = [MLUser currentUser].objectId;
    viewHistroyObj[@"viewedCourse"] = course;
    viewHistroyObj[@"courseGroup"] = self.groupObj;
    [viewHistroyObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [course incrementKey:@"viewCount"];
            [course saveInBackgroundWithBlock:nil];
            
            [self.groupObj incrementKey:@"learnedCount"];
            [self.groupObj saveInBackgroundWithBlock:nil];
        }
    }];
    
    NSURL *courseURL = [NSURL URLWithString:course[@"videoURL"]];
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    AVPlayer *player = [AVPlayer playerWithURL:courseURL];
    [player play];
    playerVC.player = player;
    
    [self presentViewController:playerVC animated:YES completion:nil];
}

#pragma mark - actions
- (void)addCommentAction:(UIBarButtonItem *)item {
    MEWriteCommentVC *writeComentVC = [[MEWriteCommentVC alloc] init];
    writeComentVC.courseGroupObj = self.groupObj;
    writeComentVC.delegate = self;
    [self.navigationController pushViewController:writeComentVC animated:YES];
}

- (void)shareAction:(UIBarButtonItem *)item {
    
    if (self.coursesInGroup.count <= 0) {
        [SVProgressHUD showErrorWithStatus:@"没有视频可以分享"];
        return;
    }
    
    [SVProgressHUD showWithStatus:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 腾讯，微博，微信都支持以下字段
        MLShareItem *shareItem = [MLShareItem itemWithMediaType:MLSContentMediaTypeVideo];
        shareItem.title = self.groupObj[@"groupName"];
        shareItem.detail = self.groupObj[@"courseDes"];
        NSURL *coverImgURL = [NSURL URLWithString:self.groupObj[@"coverImgURL"]];
        // 微信分享 要求图片大小 < 40 k
//        shareItem.previewImageData = [NSData dataWithContentsOfURL:coverImgURL];
        
        MLObject *firstCourse = self.coursesInGroup.firstObject;
        shareItem.webpageURL = [NSURL URLWithString:firstCourse[@"videoURL"]];
        shareItem.attachmentURL = [NSURL URLWithString:firstCourse[@"videoURL"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            //        [MaxSocialShare shareItem:webpageItem completion:^(MLSActivityType activityType, BOOL completed, NSError * _Nullable activityError) {
            //            NSLog(@"error = %@", activityError);
            //            if (completed) {
            //                [SVProgressHUD showSuccessWithStatus:@"分享成功!"];
            //            } else {
            //                [SVProgressHUD showErrorWithStatus:@"分享失败!"];
            //            }
            //        }];
            
            // 若要兼容iPad， 需要container
            MaxSocialContainer *container = [MaxSocialContainer containerWithRect:self.view.frame inView:self.view];
            [MaxSocialShare shareItem:shareItem withContainer:container completion:^(MLSActivityType activityType, BOOL completed, NSError * _Nullable activityError) {
                NSLog(@"error = %@", activityError);
                if (completed) {
                    [SVProgressHUD showSuccessWithStatus:@"分享成功!"];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"分享失败!"];
                }
            }];
        });
    });
}

- (void)segementButtonAction:(UIButton *)sender {
    if (sender == self.lastSelectedBtn) {
        return;
    }
    
    self.lastSelectedBtn.selected = NO;
    sender.selected = YES;
    self.lastSelectedBtn = sender;
    
    if (sender.tag == 1000) {
        [self selectedDescriptionSegment];
    } else if (sender.tag == 1001) {
        [self selectedContentListSegment];
    } else {
        [self selectedCommentSegment];
    }
}

- (void)selectedDescriptionSegment {
    CGRect rect = CGRectMake(0, kButtonCaontainerH - 2, CGRectGetWidth(self.indicatorView.bounds), 2);
    [self animateIndicatorToRect:rect];
    
    [self.tableView reloadData];
}

- (void)selectedContentListSegment {
    CGRect rect = CGRectMake(CGRectGetWidth(self.indicatorView.bounds), kButtonCaontainerH - 2, CGRectGetWidth(self.indicatorView.bounds), 2);
    [self animateIndicatorToRect:rect];
    
    MLQuery *courseQuery = [MLQuery queryWithClassName:@"MECourse"];
    [courseQuery whereKey:@"belongToGroupID" equalTo:self.groupObj.objectId];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [courseQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        self.coursesInGroup = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)selectedCommentSegment {
    CGRect rect = CGRectMake(CGRectGetWidth(self.indicatorView.bounds) * 2, kButtonCaontainerH - 2, CGRectGetWidth(self.indicatorView.bounds), 2);
    [self animateIndicatorToRect:rect];
    
    MLQuery *commentQuery = [MLQuery queryWithClassName:@"MEComment"];
    [commentQuery whereKey:@"belongToCourseID" equalTo:self.groupObj.objectId];
    [commentQuery includeKey:@"commenter"];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (objects.count) {
            self.commentsForGroup = [objects sortedArrayUsingComparator:^NSComparisonResult(MLObject*  _Nonnull obj1, MLObject* _Nonnull obj2) {
                NSDate *date1 = obj1.createdAt;
                NSDate *date2 = obj2.createdAt;
                return [date2 compare:date1];
            }];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)animateIndicatorToRect:(CGRect)rect {
    [UIView animateWithDuration:0.3 animations:^{
        self.indicatorView.frame = rect;
    }];
}

#pragma mark - setters & getters
- (UIView *)topContainer {
    if (!_topContainer) {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        _topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, width, kTopContainerH)];
        
        UIImageView *courseCoverImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, kTopContainerH - kButtonCaontainerH)];
        courseCoverImgView.contentMode = UIViewContentModeScaleAspectFill;
        [courseCoverImgView sd_setImageWithURL:[NSURL URLWithString:self.groupObj[@"coverImgURL"]] placeholderImage:ImageNamed(@"default")];
        courseCoverImgView.clipsToBounds = YES;
        [_topContainer addSubview:courseCoverImgView];
        
        self.buttonContainer.frame = CGRectMake(0, kTopContainerH - kButtonCaontainerH, width, kButtonCaontainerH);
        [_topContainer addSubview:self.buttonContainer];
    }
    return _topContainer;
}

- (UIView *)buttonContainer {
    if (!_buttonContainer) {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        _buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, kButtonCaontainerH)];
        [_buttonContainer addBottomBorderWithColor:UIColorFromRGBA(0, 0, 0, 0.1) width:1];
        
        CGFloat btnW = width / 3;
        CGFloat btnH = kButtonCaontainerH - 2;
        NSArray *btnTitles = @[@"简介", @"目录", @"评价"];
        for (NSInteger i = 0; i < btnTitles.count; i ++) {
            CGFloat btnX = btnW * i;
            NSString *title = btnTitles[i];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, 0, btnW, btnH)];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGBA(47, 49, 53, 1) forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGBA(51, 178, 151, 1) forState:UIControlStateSelected];
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(segementButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonContainer addSubview:btn];
            
            if (i == 0) {
                [self segementButtonAction:btn];
            }
            
            if (i == 2) {
                self.commentBtn = btn;
            }
        }
        
        self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, kButtonCaontainerH - 2, btnW, 2)];
        self.indicatorView.backgroundColor = UIColorFromRGBA(51, 178, 151, 1);
        [_buttonContainer addSubview:self.indicatorView];
    }
    return _buttonContainer;
}

- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame = CGRectMake(0, kTopContainerH + 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kTopContainerH);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[MEContentListCell class] forCellReuseIdentifier:kContentListCell];
        [_tableView registerClass:[MECommentCell class] forCellReuseIdentifier:kCommentCell];
        [_tableView registerClass:[MECourseDescCell class] forCellReuseIdentifier:kDesCell];
        [_tableView registerClass:[MEDescTeacherCell class] forCellReuseIdentifier:kDesTeacherCell];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end


#pragma mark - MEContentListCell
@interface MEContentListCell ()
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *videoIconImgView;
@property (nonatomic, strong) UILabel *courseTitleLabel;
@end

@implementation MEContentListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.numLabel = [[UILabel alloc] init];
    self.numLabel.textAlignment = NSTextAlignmentRight;
    self.numLabel.textColor = UIColorFromRGBA(116, 118, 120, 0.8);
    
    self.videoIconImgView = [[UIImageView alloc] init];
    self.videoIconImgView.image = ImageNamed(@"icn_palyvedio");
    
    self.courseTitleLabel = [[UILabel alloc] init];
    self.courseTitleLabel.textColor = UIColorFromRGBA(116, 118, 120, 0.8);
    
    [self.contentView addSubview:self.numLabel];
    [self.contentView addSubview:self.videoIconImgView];
    [self.contentView addSubview:self.courseTitleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    self.numLabel.frame = CGRectMake(0, 0, 80, height);
    
    CGFloat iconW = 15;
    CGFloat iconX = CGRectGetMaxX(self.numLabel.frame) + 18;
    CGFloat iconY = (height - iconW) / 2;
    self.videoIconImgView.frame = CGRectMake(iconX, iconY, iconW, iconW);
    
    CGFloat titleX = CGRectGetMaxX(self.videoIconImgView.frame) + 10;
    CGFloat titleW = width - titleX;
    self.courseTitleLabel.frame = CGRectMake(titleX, 0, titleW, height);
}

- (void)updateContentWithCourseName:(NSString *)courseName forIndexPath:(NSIndexPath *)indexPath {
    self.numLabel.text = [NSString stringWithFormat:@"%2ld", (long)indexPath.row + 1];
    self.courseTitleLabel.text = courseName;
}

@end


#pragma mark - MECommentCell
@interface MECommentCell ()
@property (nonatomic, strong) UIImageView *userIconView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation MECommentCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat iconW = 42;
    self.userIconView.frame = CGRectMake(border, border, iconW, iconW);
    self.userIconView.layer.cornerRadius = iconW / 2;
    self.userIconView.clipsToBounds = YES;
    
    CGFloat labelX = CGRectGetMaxX(self.userIconView.frame) + 10;
    CGFloat labelW = width - labelX;
    CGFloat labelH = (height - border * 2 - 5*2) / 3;
    self.userNameLabel.frame = CGRectMake(labelX, border, labelW, labelH);
    
    CGFloat timeY = CGRectGetMaxY(self.userNameLabel.frame) + 5;
    self.timeLabel.frame = CGRectMake(labelX, timeY, labelW, labelH);
    
    CGFloat contentY = CGRectGetMaxY(self.timeLabel.frame) + 5;
    self.contentLabel.frame = CGRectMake(labelX, contentY, labelW, labelH);
}

- (void)initSubViews {
    self.userIconView = [[UIImageView alloc] init];
    
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.font = [UIFont systemFontOfSize:14];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textColor = UIColorFromRGBA(185, 185, 185, 0.8);
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.textColor = UIColorFromRGBA(0, 0, 0, 0.8);
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    
    [self.contentView addSubview:self.userIconView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentLabel];
}

- (void)updateContentWithCommentObj:(MLObject *)commentObj {
    MLUser *commenter = commentObj[@"commenter"];
    NSURL *iconURL = [NSURL URLWithString:[commenter objectForKey:@"iconUrl"]];
    [self.userIconView sd_setImageWithURL:iconURL placeholderImage:ImageNamed(@"ic_comment_head")];
    self.userNameLabel.text = commenter.username.length ? commenter.username : @"游客";
    self.timeLabel.text = [self formatedStringWithDate:commentObj.createdAt];
    self.contentLabel.text = commentObj[@"content"];
}

- (NSString *)formatedStringWithDate:(NSDate *)date {
    NSDate *dateNow = [NSDate date];
    NSString *result = @"";
    
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceDate:date];
    if (timeInterval < 60) {
        result = @"刚刚";
    } else if (timeInterval < 60 * 60) {
        NSInteger mins = (NSInteger)(timeInterval / 60);
        result = [NSString stringWithFormat:@"%ld 分钟前", (long)mins];
    } else if (timeInterval < 24 * 60 * 60) {
        NSInteger hours = (NSInteger)(timeInterval / 3600);
        result = [NSString stringWithFormat:@"%ld 小时前", (long)hours];
    } else {
        result = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    }
    
    return result;
}
@end
