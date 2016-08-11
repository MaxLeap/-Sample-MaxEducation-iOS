//
//  MEPersonViewController.m
//  MaxEducation
//
//  Created by luomeng on 16/6/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEPersonViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "UIImage+Resize.h"
#import "MCPersonalViewController.h"
#import "MESettingsViewController.h"
#import "MECourseDetailViewController.h"

NSString * const kHistoryInfoCoverImage = @"historyInfoCoverImg";
NSString * const kHistoryInfoTitle = @"historyInfoTitle";
NSString * const kHistoryInfoDes = @"historyInfoDes";

static NSInteger const kLastLearnBtnTag = 2001;
static NSInteger const kLearnedBtnTag = 2002;
static NSInteger const kMyUploadBtnTag = 2003;

@interface MEPersonViewController () <UITableViewDelegate,
 UITableViewDataSource,
 DZNEmptyDataSetSource,
 DZNEmptyDataSetDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyUIView;
@property (nonatomic, strong) UIView *userInfoView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIButton *lastSelectedBtn;
@property (nonatomic, strong) UIImageView *userIconView;
@end

@implementation MEPersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self buildUI];
    
    [self refreshUserIcon];
}

- (void)buildUI {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if ([MEMLUserHelper hasLogin]) {
        // config user info
        [self showUserInfoView];
    } else {
        self.dataSource = nil;
        [self showEmptyView];
    }
}

-  (void)refreshUserIcon {
    MLUser *currentUser = [MLUser currentUser];
    NSURL *iconURL = [NSURL URLWithString:[currentUser objectForKey:@"iconUrl"]];
    [self.userIconView sd_setImageWithURL:iconURL placeholderImage:ImageNamed(@"ic_comment_head")];
}

- (void)showUserInfoView {
    [self.view addSubview:self.userInfoView];
    
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat offsetY = CGRectGetMaxY(self.userInfoView.frame);
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.tableView.frame = CGRectMake(0, offsetY, width, height - offsetY);
    
    [self.view addSubview:self.tableView];
}

- (void)showEmptyView {
    [self.view addSubview:self.emptyUIView];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MEHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *info;
    if (self.lastSelectedBtn.tag == kLastLearnBtnTag) {
        MLObject *courseGroup = self.dataSource[indexPath.row];
        
        NSDate *lastLearnDate = courseGroup[@"tempCreateAt"];
        NSDate *dateNow = [NSDate new];
        NSTimeInterval interval = [dateNow timeIntervalSinceDate:lastLearnDate];
        NSInteger dayCount = interval / (24 * 3600);
        info = @{
                 kHistoryInfoCoverImage: courseGroup[@"coverImgURL"],
                 kHistoryInfoTitle : courseGroup[@"groupName"],
                 kHistoryInfoDes : [NSString stringWithFormat:@"上次学习%ld天之前", (long)dayCount]
                 };
    } else if (self.lastSelectedBtn.tag == kLearnedBtnTag) {
        MLObject *courseGroup = self.dataSource[indexPath.row];
        info = @{
                 kHistoryInfoCoverImage: courseGroup[@"coverImgURL"],
                 kHistoryInfoTitle : courseGroup[@"groupName"],
                 kHistoryInfoDes : [NSString stringWithFormat:@"已学%@/%@课程", courseGroup[@"tempLearnCourse"], courseGroup[@"courseCount"]]
                 };
    } else {
        MLObject *courseGroup = self.dataSource[indexPath.row];
        info = @{
            kHistoryInfoCoverImage: courseGroup[@"coverImgURL"],
                kHistoryInfoTitle : courseGroup[@"groupName"],
                  kHistoryInfoDes : [NSString stringWithFormat:@"已有%@人学习", courseGroup[@"learnedCount"]]
                               };
    }
    [cell updateCellWithContentDic:info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLObject *courseGroup = self.dataSource[indexPath.row];
    [self toShowCourseDetailInfo:courseGroup];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"没有记录";
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:title attributes:@{
                    NSFontAttributeName : [UIFont systemFontOfSize:15]
                }];
    return attStr;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - actions
- (void)toShowCourseDetailInfo:(MLObject *)courseGroup {
    if (courseGroup) {
        MECourseDetailViewController *detailVC = [[MECourseDetailViewController alloc] init];
        detailVC.groupObj = courseGroup;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)showSettings {
    MESettingsViewController *settingsVC = [[MESettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)toLoginAction:(UIButton *)sender {
    NSLog(@"to log in");
    MCPersonalViewController *personalVC = [[MCPersonalViewController alloc] initWithNibName:@"MCPersonalViewController" bundle:nil];
    [self.navigationController pushViewController:personalVC animated:YES];
}

- (void)showLoggedUserInfo:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"show logged user info");
    MCPersonalViewController *personalVC = [[MCPersonalViewController alloc] initWithNibName:@"MCPersonalViewController" bundle:nil];
    [self.navigationController pushViewController:personalVC animated:YES];
}

- (void)changeContentAction:(UIButton *)sender {
    if (sender == self.lastSelectedBtn) {
        return;
    }
    
    NSLog(@"change account");
    self.lastSelectedBtn.selected = NO;
    sender.selected = YES;
    if (sender.tag == kLastLearnBtnTag) {
        [self fetchMyLastLearnedCourse];
    } else if (sender.tag == kLearnedBtnTag) {
        [self fetchMyLearnedCourse];
    } else {
        [self fetchMyUploadCourse];
    }
    
    self.lastSelectedBtn = sender;
}

- (void)fetchMyLastLearnedCourse {
    if ([MEMLUserHelper hasLogin]) {
        MLUser *currentUser = [MLUser currentUser];
        
        MLQuery *lastLearnedQuery = [MLQuery queryWithClassName:@"MEViewHistory"];
        [lastLearnedQuery whereKey:@"viewerID" equalTo:currentUser.objectId];
        [lastLearnedQuery includeKey:@"viewedCourse"];
        [lastLearnedQuery includeKey:@"courseGroup"];
        [SVProgressHUD showWithStatus:@"Loading..."];
        [lastLearnedQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count) {
                
                NSMutableDictionary *mTempResult = [[NSMutableDictionary alloc] init];
                NSMutableArray *courseIds = [[NSMutableArray alloc] init];
                NSMutableArray *groupIds = [[NSMutableArray alloc] init];
                for (MLObject *viewHistoryObj in objects) {
                    MLObject *courseObj = viewHistoryObj[@"viewedCourse"];
                    MLObject *courseGroupObj = viewHistoryObj[@"courseGroup"];
                    
                    if ([groupIds containsObject:courseGroupObj.objectId]) {
                        NSDate *viewDate = viewHistoryObj.createdAt;
                        
                        MLObject *savedGoupObj = [mTempResult valueForKey:courseGroupObj.objectId];
                        NSDate *savedCreateAt = savedGoupObj[@"tempCreateAt"];
                        
                        if ([savedCreateAt compare:viewDate] == NSOrderedAscending) {
                            savedGoupObj[@"tempCreateAt"] = viewDate;
                        }
                        
                    } else {
                        [groupIds addObject:courseGroupObj.objectId];
                        [courseIds addObject:courseObj.objectId];
                        
                        courseGroupObj[@"tempCreateAt"] = viewHistoryObj.createdAt;
                        [mTempResult setObject:courseGroupObj forKey:courseGroupObj.objectId];
                    }
                }
                
                
                NSArray *result = [mTempResult allValues];
                self.dataSource = result;
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
            });
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    }
}

- (void)fetchMyLearnedCourse {
    if ([MEMLUserHelper hasLogin]) {
        MLUser *currentUser = [MLUser currentUser];
        
        MLQuery *lastLearnedQuery = [MLQuery queryWithClassName:@"MEViewHistory"];
        [lastLearnedQuery whereKey:@"viewerID" equalTo:currentUser.objectId];
        [lastLearnedQuery includeKey:@"viewedCourse"];
        [lastLearnedQuery includeKey:@"courseGroup"];
        [SVProgressHUD showWithStatus:@"Loading..."];
        [lastLearnedQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count) {
                NSMutableDictionary *mTempResult = [[NSMutableDictionary alloc] init];
                NSMutableArray *courseIds = [[NSMutableArray alloc] init];
                NSMutableArray *groupIds = [[NSMutableArray alloc] init];
                for (MLObject *viewHistoryObj in objects) {
                    MLObject *courseObj = viewHistoryObj[@"viewedCourse"];
                    MLObject *courseGroupObj = viewHistoryObj[@"courseGroup"];
                    
                    if ([groupIds containsObject:courseGroupObj.objectId]) {
                        if (![courseIds containsObject:courseObj.objectId]) {
                            [courseIds addObject:courseObj.objectId];
                            
                            MLObject *addedGroupObj = [mTempResult valueForKey:courseGroupObj.objectId];
                            NSInteger hasLearnCount = [addedGroupObj[@"tempLearnCourse"] integerValue];
                            hasLearnCount ++;
                            addedGroupObj[@"tempLearnCourse"] = @(hasLearnCount);
                        }
                    } else {
                        [groupIds addObject:courseGroupObj.objectId];
                        [courseIds addObject:courseObj.objectId];
                        
                        courseGroupObj[@"tempLearnCourse"] = @(1);
                        [mTempResult setObject:courseGroupObj forKey:courseGroupObj.objectId];
                    }
                }
                
                NSArray *results = [mTempResult allValues];
                self.dataSource = results;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
            });
            
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    }
}

- (void)fetchMyUploadCourse {
    if ([MEMLUserHelper hasLogin]) {
        MLUser *currentUser = [MLUser currentUser];
        
        MLQuery *courseQuery = [MLQuery queryWithClassName:@"MECourseGroup"];
        [courseQuery includeKey:@"publisher"];
        [courseQuery orderByDescending:@"createdAt"];
        [courseQuery whereKey:@"uploadUserId" equalTo:currentUser.objectId];
        [SVProgressHUD showWithStatus:@"Loading..."];
        [courseQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count) {
                self.dataSource = objects;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
            });
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    }
}


#pragma mark - setter & getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[MEHistoryCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 110.0f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
    }
    return _tableView;
}

- (UIView *)userInfoView {
    if (!_userInfoView) {
        CGFloat infoViewH = 200 + 64;
        CGFloat width = CGRectGetWidth(self.view.bounds);
        _userInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, infoViewH)];
        _userInfoView.backgroundColor = UIColorFromRGBA(51, 178, 151, 1);
        
        CGFloat iconW = 75;
        CGFloat iconX = (width - iconW) / 2;
        CGFloat iconY = (infoViewH - iconW) / 2;
        UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconW, iconW)];
        userIconView.userInteractionEnabled = YES;
        userIconView.layer.cornerRadius = iconW / 2;
        userIconView.clipsToBounds = YES;
        userIconView.layer.borderWidth = 2;
        userIconView.layer.borderColor = [UIColor whiteColor].CGColor;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLoggedUserInfo:)];
        [userIconView addGestureRecognizer:tapGesture];
        [_userInfoView addSubview:userIconView];
        self.userIconView = userIconView;
        
        CGFloat labelY = CGRectGetMaxY(userIconView.frame) + 3;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, width, 30)];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [_userInfoView addSubview:nameLabel];
        
        CGFloat containerY = CGRectGetMaxY(nameLabel.frame) + 3;
        CGRect btnContainerFrame = CGRectMake(0, containerY, width, infoViewH - containerY);
        [_userInfoView addSubview:[self bottomBtnContainerWithFrame:btnContainerFrame]];
        
        MLUser *currentUser = [MLUser currentUser];
        nameLabel.text = currentUser.username;
        NSURL *iconURL = [NSURL URLWithString:[currentUser objectForKey:@"iconUrl"]];
        [userIconView sd_setImageWithURL:iconURL placeholderImage:ImageNamed(@"ic_comment_head")];
        
    }
    return _userInfoView;
}

- (UIView *)bottomBtnContainerWithFrame:(CGRect)frame {
    UIView *btnContainer = [[UIView alloc] initWithFrame:frame];
    btnContainer.backgroundColor = [UIColor whiteColor];
    
    CGFloat btnW = (frame.size.width - 2) / 3;
    CGFloat btnH = frame.size.height - 1;
    NSArray *btnTitles = @[@"上次学习", @"已学课程", @"我的上传"];
    for (NSInteger i = 0; i < btnTitles.count; i ++) {
        CGFloat btnX = (btnW + 1) * i;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, 0, btnW, btnH)];
        [btn setTitle:btnTitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGBA(51, 178, 151, 1) forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(changeContentAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = (i == 0) ? kLastLearnBtnTag : (i == 1 ? kLearnedBtnTag : kMyUploadBtnTag);
        [btnContainer addSubview:btn];
        
        if (i < btnTitles.count - 1) {
            [btn addRightBorderWithColor:UIColorFromRGBA(209, 209, 209, 0.6) width:1 excludePoint:btnH / 3 edgeType:ExcludeAllPoint];
        }
        
        if (i == 1) {
            [self changeContentAction:btn];
        }
    }
    
    [btnContainer addBottomBorderWithColor:UIColorFromRGBA(209, 209, 209, 0.6) width:1];
    
    return btnContainer;
}

- (UIView *)emptyUIView {
    if (!_emptyUIView) {
        _emptyUIView = [[UIView alloc] initWithFrame:self.view.bounds];
        _emptyUIView.backgroundColor = [UIColor whiteColor];
        
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGFloat height = CGRectGetHeight(self.view.bounds);
        CGFloat iconW = 51;
        UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake((width - iconW) / 2, height / 2 - iconW, iconW, iconW)];
        userIconView.image = ImageNamed(@"ic_comment_head");
        [_emptyUIView addSubview:userIconView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height / 2 + 3, width, 60)];
        textLabel.attributedText = [self attributeText];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.numberOfLines = 2;
        [_emptyUIView addSubview:textLabel];
        
        CGFloat btnW = 150;
        CGFloat btnY = CGRectGetMaxY(textLabel.frame) + 2;
        CGFloat btnH = 47;
        UIButton *toLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake((width - btnW) / 2, btnY, btnW, btnH)];
        toLoginBtn.layer.cornerRadius = btnH / 2;
        toLoginBtn.clipsToBounds = YES;
        [toLoginBtn setTitle:@"登录/注册" forState:UIControlStateNormal];
        [toLoginBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(51, 178, 151, 1)] forState:UIControlStateNormal];
        [toLoginBtn addTarget:self action:@selector(toLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        [_emptyUIView addSubview:toLoginBtn];
    }
    return _emptyUIView;
}

- (NSAttributedString *)attributeText {
    NSString *text = @"您尚未登录\n无法记录和同步学习状态，建议登录";
    NSAttributedString *attText = [[NSAttributedString alloc] initWithString:text attributes:@{}];
    return attText;
}
@end


#pragma mark - MEHistoryCell
@interface MEHistoryCell ()
@property (nonatomic, strong) UIImageView *courseImageView;
@property (nonatomic, strong) UILabel *courseNameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@end

@implementation MEHistoryCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubview];
    }
    return self;
}

- (void)initSubview {
    [self.contentView addSubview:self.courseImageView];
    [self.contentView addSubview:self.courseNameLabel];
    [self.contentView addSubview:self.descLabel];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.courseImageView sd_cancelCurrentImageLoad];
    self.courseImageView.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat startX = 10;
    CGFloat startY = 15;
    
    CGFloat imgW = 141;
    CGFloat imgH = height - startY * 2;
    self.courseImageView.frame = CGRectMake(startX, startY, imgW, imgH);
    
    CGFloat labelX = CGRectGetMaxX(self.courseImageView.frame) + 10;
    self.courseNameLabel.frame = CGRectMake(labelX, startY, width - labelX, 20);
    
    CGFloat desLH = 15;
    CGFloat desLY = CGRectGetMaxY(self.courseImageView.frame) - desLH;
    self.descLabel.frame = CGRectMake(labelX, desLY, width - labelX, desLH);
}

- (void)updateCellWithContentDic:(NSDictionary *)contentDic {
    NSURL *imgURL = [NSURL URLWithString:contentDic[kHistoryInfoCoverImage]];
    [self.courseImageView sd_setImageWithURL:imgURL placeholderImage:ImageNamed(@"default")];
    
    self.courseNameLabel.text = contentDic[kHistoryInfoTitle];
    
    self.descLabel.text = contentDic[kHistoryInfoDes];
}

#pragma mark - setters & getters
- (UIImageView *)courseImageView {
    if (!_courseImageView) {
        _courseImageView = [[UIImageView alloc] init];
        _courseImageView.contentMode = UIViewContentModeScaleAspectFill;
        _courseImageView.clipsToBounds = YES;
    }
    return _courseImageView;
}

- (UILabel *)courseNameLabel {
    if (!_courseNameLabel) {
        _courseNameLabel = [[UILabel alloc] init];
    }
    return _courseNameLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textColor = UIColorFromRGBA(211, 212, 213, 1);
        _descLabel.font = [UIFont systemFontOfSize:13];
    }
    return _descLabel;
}
@end