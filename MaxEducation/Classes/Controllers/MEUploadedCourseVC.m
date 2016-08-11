//
//  MEUploadedCourseVC.m
//  MaxEducation
//
//  Created by luomeng on 16/6/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEUploadedCourseVC.h"
#import "UIScrollView+EmptyDataSet.h"
#import "MEUploadViewController.h"
#import "MECourseManager.h"
#import "MECourseGroupCell.h"
#import "MECourseDetailViewController.h"

#import "MJRefresh.h"

@interface MEUploadedCourseVC () <UITableViewDelegate,
 UITableViewDataSource,
 DZNEmptyDataSetSource,
 DZNEmptyDataSetDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *uploadedCourseGroups;

@end

@implementation MEUploadedCourseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL enableUpload = NO;
    if ([MEMLUserHelper hasLogin]) {
        enableUpload = YES;
//        [self fetchMyUploadedCourseGroup];
        
        [self addRefresh];
    }
    
    [self buildUIEnableUpload:enableUpload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([MEMLUserHelper hasLogin]) {
        [self fetchMyUploadedCourseGroup];
    }
}

- (void)addRefresh {
    
    __weak MEUploadedCourseVC *weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf fetchMyUploadedCourseGroup];
    }];
    self.tableView.header.updatedTimeHidden = YES;
    self.tableView.header.stateHidden = YES;
    [self.tableView.header beginRefreshing];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uploadedCourseGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MECourseGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    MLObject *courseGroupObj = self.uploadedCourseGroups[indexPath.row];
    NSDictionary *info = @{
                           kInfoImgURL: courseGroupObj[@"coverImgURL"],
                       kInfoCourseName: courseGroupObj[@"groupName"],
                         kInfoSubTitle: [NSString stringWithFormat:@"%@ 个视频", courseGroupObj[@"courseCount"]]
                           };
    [cell updateContentWithInfo:info];
    
    MEUploadedCourseVC *__weak wself = self;
    cell.addCourseBlock = ^() {
        [wself toAddCourseForGroup:courseGroupObj];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLObject *groupObj = self.uploadedCourseGroups[indexPath.row];
    [self toShowCourseDetailInfo:groupObj];
}

#pragma mark - EmptyData set
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return ImageNamed(@"img_shanchaunkecheng");
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"你没有上传任何课程\n快来上传吧~";
    if (![MEMLUserHelper hasLogin]) {
        title = @"你还没有登录\n请先登录";
    }
    NSAttributedString *attTitle = [[NSAttributedString alloc] initWithString:title attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:15],
                NSForegroundColorAttributeName: UIColorFromRGBA(181, 181, 183, 1)
            }];
    return attTitle;
}

#pragma mark - private method
- (void)buildUIEnableUpload:(BOOL)enableUpload {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"我的上传";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStylePlain target:self action:@selector(toUploadCourse:)];
    rightItem.tintColor = [UIColor whiteColor];
    rightItem.enabled = enableUpload;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.tableView];
}

static bool __isFetchingCourseGroup = NO;
- (void)fetchMyUploadedCourseGroup {
    if (__isFetchingCourseGroup) {
        return;
    }
    
    __isFetchingCourseGroup = YES;
//    [SVProgressHUD showWithStatus:@"Loading..."];
    [[MECourseManager sharedManager] fetchMyUploadedCourseGroupCompletedHandler:^(NSArray *uploadedObjs, NSError *error) {
        [self.tableView.header endRefreshing];
        __isFetchingCourseGroup = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:@"error"];
            } else {
//                [SVProgressHUD dismiss];
                self.uploadedCourseGroups = uploadedObjs;
                [self.tableView reloadData];
            }
        });
    }];
}

- (void)toUploadCourse:(UIBarButtonItem *)item {
    MEUploadViewController *uploadViewController = [[MEUploadViewController alloc] init];
    [self.navigationController pushViewController:uploadViewController animated:YES];
}

- (void)toAddCourseForGroup:(MLObject *)courseGroupObj {
    MEUploadViewController *uploadCourseVC = [[MEUploadViewController alloc] init];
    uploadCourseVC.courseGroup = courseGroupObj;
    [self.navigationController pushViewController:uploadCourseVC animated:YES];
}

- (void)toShowCourseDetailInfo:(MLObject *)courseGroupObj {
    MECourseDetailViewController *detailVC = [[MECourseDetailViewController alloc] init];
    detailVC.groupObj = courseGroupObj;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - setter & getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[MECourseGroupCell class] forCellReuseIdentifier:@"cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 110.0f;
    }
    return _tableView;
}

@end
