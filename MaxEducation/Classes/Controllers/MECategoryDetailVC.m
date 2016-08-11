//
//  MECategoryDetailVC.m
//  MaxEducation
//
//  Created by luomeng on 16/6/22.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MECategoryDetailVC.h"
#import "MEHomeCourseListCell.h"
#import "MECourseDetailViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "UIBarButtonItem+Custom.h"
#import "MESearchViewController.h"

#import "MJRefresh.h"

static NSString * const kCellID = @"cellId";

@interface MECategoryDetailVC () <UITableViewDelegate,
 UITableViewDataSource,
 DZNEmptyDataSetSource,
 DZNEmptyDataSetDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *courseGroups;
@end

@implementation MECategoryDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildUI];
    
//    [self fetchCourseGroupsInCurrentCate];
    
    [self addRefresh];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.cateObj[@"name"];
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem barButtonItemWithNormalImagenName:@"icn_search_nav" selectedImageName:nil target:self action:@selector(searchAction:)];
    barButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    [self.view addSubview:self.tableView];
}

- (void)addRefresh {
    
    __weak MECategoryDetailVC *weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf fetchCourseGroupsInCurrentCate];
    }];
    self.tableView.header.updatedTimeHidden = YES;
    self.tableView.header.stateHidden = YES;
    [self.tableView.header beginRefreshing];
}

- (void)fetchCourseGroupsInCurrentCate {
    
    MLQuery *groupQuery = [MLQuery queryWithClassName:@"MECourseGroup"];
    [groupQuery whereKey:@"belongToCategoryID" equalTo:self.cateObj.objectId];
    [groupQuery includeKey:@"publisher"];
    [groupQuery orderByDescending:@"createdAt"];
//    [SVProgressHUD showWithStatus:@"Loading..."];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.tableView.header endRefreshing];
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
        } else {
            self.courseGroups = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courseGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MEHomeCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    
    MLObject *courseGroup = self.courseGroups[indexPath.row];
    [cell updateContentWithCourse:courseGroup];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLObject *groupObj = self.courseGroups[indexPath.row];
    if (groupObj) {
        [self toShowCourseGroupDetail:groupObj];
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *plainTxt = @"该分类没有课程";
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:plainTxt attributes:@{
                       NSFontAttributeName : [UIFont systemFontOfSize:15],
            NSForegroundColorAttributeName : UIColorFromRGBA(0, 0, 0, 0.7)}];
    return attString;
}

#pragma mark - actions
- (void)toShowCourseGroupDetail:(MLObject *)courseGroupObj {
    MECourseDetailViewController *detailVC = [[MECourseDetailViewController alloc] init];
    detailVC.groupObj = courseGroupObj;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)searchAction:(UIButton *)sender {
    MESearchViewController *searchVC = [[MESearchViewController alloc] init];
    UINavigationController *navSearchVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
    searchVC.searchInCateObj = self.cateObj;
    [self presentViewController:navSearchVC animated:NO completion:nil];
}

#pragma mark - getters & setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.rowHeight = 110.0f;
        [_tableView registerClass:[MEHomeCourseListCell class] forCellReuseIdentifier:kCellID];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
