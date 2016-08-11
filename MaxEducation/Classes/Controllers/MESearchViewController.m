//
//  MESearchViewController.m
//  MaxEducation
//
//  Created by luomeng on 16/6/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MESearchViewController.h"
#import "MEKeyWordView.h"
#import "MECourseGroupCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "MECourseDetailViewController.h"

static NSString * const kCellID = @"cellID";

@interface MESearchViewController () <UISearchBarDelegate,
 UITableViewDelegate,
 UITableViewDataSource,
 DZNEmptyDataSetSource,
 DZNEmptyDataSetDelegate,
 MEKeyWordViewProtocol
>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *keywords;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) BOOL hasSearch;
@end

@implementation MESearchViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.keywords = self.searchInCateObj[@"searchKeyWord"];
    if (!self.searchInCateObj) {
        self.keywords = @[@"英语", @"金融", @"java", @"UI", @"安卓", @"PPT"];
    }
    
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.searchResults.count <= 0) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)dealloc {
    [SVProgressHUD dismiss];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MECourseGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    MLObject *courseGroupObj = self.searchResults[indexPath.row];
    NSDictionary *info = @{
                           kInfoImgURL: courseGroupObj[@"coverImgURL"],
                           kInfoCourseName: courseGroupObj[@"groupName"],
                           kInfoSubTitle: [NSString stringWithFormat:@"%@ 个视频", courseGroupObj[@"courseCount"]]
                           };
    [cell updateContentWithInfo:info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.searchBar resignFirstResponder];
    MLObject *courseGroup = self.searchResults[indexPath.row];
    [self toShowCourseDetalInfo:courseGroup];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.hasSearch) {
        NSString *plainTxt = @"没有结果";
        NSAttributedString *attTxt = [[NSAttributedString alloc] initWithString:plainTxt attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
        return attTxt;
    }
    return nil;
}

#pragma mark - UISearchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    if (searchText.length) {
        [self startSearch:searchText];
    }
    [searchBar resignFirstResponder];
    NSLog(@"search text = %@", searchText);
}

#pragma mark - MEKeyWordView delegate
- (void)didTappedKeyWord:(NSString *)keyWord {
    [self.searchBar resignFirstResponder];
    self.searchBar.text = keyWord;
    
    [self startSearch:keyWord];
}

#pragma mark - private method
- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
    
    self.navigationItem.titleView = self.searchBar;
    
    [self.view addSubview:self.tableView];
}

- (void)toShowCourseDetalInfo:(MLObject *)courseGroup {
    if (courseGroup) {
        MECourseDetailViewController *detailVC = [[MECourseDetailViewController alloc] init];
        detailVC.groupObj = courseGroup;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)cancelAction:(UIBarButtonItem *)item {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)startSearch:(NSString *)searchText {
    NSLog(@"start search text = %@", searchText);
    [SVProgressHUD showWithStatus:@"search..."];
    MLQuery *groupQuery = [MLQuery queryWithClassName:@"MECourseGroup"];
    [groupQuery includeKey:@"publisher"];
    [groupQuery whereKey:@"groupName" containsString:searchText];
    if (self.searchInCateObj) {
        [groupQuery whereKey:@"belongToCategoryID" equalTo:self.searchInCateObj.objectId];
    }
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.hasSearch = YES;
        if (!error) {
            self.searchResults = objects;
            if (objects.count) {
                self.tableView.tableHeaderView = nil;
            } else {
                self.tableView.tableHeaderView = [self tableHeaderView];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"请求失败"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        });
    }];
}

#pragma mark - setter & getter
- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 260, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索课程";
    }
    return _searchBar;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[MECourseGroupCell class] forCellReuseIdentifier:kCellID];
        _tableView.rowHeight = 110.0;
        _tableView.tableHeaderView = [self tableHeaderView];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
    }
    return _tableView;
}

- (MEKeyWordView *)tableHeaderView {
    MEKeyWordView *headerView = [[MEKeyWordView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80) keyWords:self.keywords];
    headerView.delegate = self;
    return headerView;
}

@end
