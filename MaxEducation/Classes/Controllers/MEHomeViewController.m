//
//  ViewController.m
//  MaxEducation
//
//  Created by luomeng on 16/6/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEHomeViewController.h"
#import "MESearchViewController.h"
#import "MEPersonViewController.h"
#import "MEUploadedCourseVC.h"
#import "UIBarButtonItem+Custom.h"
#import "MECourseManager.h"
#import "MEHomeCourseListCell.h"
#import "MEHeaderView.h"
#import "MECourseCateButton.h"
#import "MECourseDetailViewController.h"
#import "MECategoryDetailVC.h"

static NSString * const kCellID = @"cell";

@interface MEHomeViewController () <UITableViewDelegate,
 UITableViewDataSource,
 UISearchBarDelegate,
 MEHeaderViewProtocol
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *courseCategories;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation MEHomeViewController

#pragma mark - lift cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self startFetchData];
    
    [self buildUI];
    
    [self addObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = [UIBarButtonItem barButtonItemWithNormalImagenName:@"icn_nav_homepage" highlightedImageName:@"" target:self action:@selector(showPersonViewController:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *uploadItem = [UIBarButtonItem barButtonItemWithNormalImagenName:@"icn_homepage_header_upload" highlightedImageName:@"" target:self action:@selector(showUploadViewController:)];
    self.navigationItem.rightBarButtonItem = uploadItem;
    
    self.navigationItem.titleView = self.searchBar;
    
    [self.view addSubview:self.tableView];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFetchData) name:kDidUploadCourseSuccessNotify object:nil];
}

#pragma mark - UITableView delegate & dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.courseCategories.count <= 0) {
        return 50;
    }
    return 240;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    BOOL hasCategory = self.courseCategories.count > 0;
    CGFloat height = hasCategory ? 240 : 50;
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    if (hasCategory) {
        UIView *cateContainer = [self cateButtonContainerViewWithFrame:CGRectMake(0, 0, width, 190)];
        [sectionHeader addSubview:cateContainer];
        
        UIView *bottomcontainer = [self sectionHeaderBottomViewWithFrame:CGRectMake(0, 190, width, 50)];
        [sectionHeader addSubview:bottomcontainer];
    } else {
        UIView *contentContainer = [self sectionHeaderBottomViewWithFrame:CGRectMake(0, 0, width, height)];
        [sectionHeader addSubview:contentContainer];
    }
    
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MEHomeCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    MLObject *groupObj = self.dataSource[indexPath.row];
    [cell updateContentWithCourse:groupObj];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MLObject *groupObj = self.dataSource[indexPath.row];
    if (groupObj) {
        [self toShowCourseDetail:groupObj];
    }
}

#pragma makr - UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"begin edit");
    MESearchViewController *searchVC = [[MESearchViewController alloc] init];
    UINavigationController *navSearchVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:navSearchVC animated:NO completion:nil];
    return NO;
}

#pragma mark - MEHeaderViewProtocol
- (void)didTappedCourseGroup:(MLObject *)courseGroup {
    [self toShowCourseDetail:courseGroup];
}

#pragma mark - private methods
- (void)startFetchData {
    
    static NSInteger finishTimes = 0;
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[MECourseManager sharedManager] fetchCourseCategoryIfNeededCompleteHandler:^(NSArray *cateObjs, NSError *error) {
        finishTimes ++;
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        } else {
            self.courseCategories = cateObjs.count > 8 ? [cateObjs subarrayWithRange:NSMakeRange(0, 8)] : cateObjs;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                
                if (finishTimes >= 2) {
                    [SVProgressHUD dismiss];
                }
            });
        }
    }];
    
    [[MECourseManager sharedManager] fetchHotCourseIfNeededCompleteHandler:^(NSArray *courseGroups, NSError *error) {
        finishTimes ++;
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        } else {
            self.dataSource = courseGroups;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self refreshTableHeaderView];
                
                if (finishTimes >= 2) {
                    [SVProgressHUD dismiss];
                }
            });
        }
    }];
}

- (void)refreshTableHeaderView {
    if (self.dataSource.count <= 0) {
        return;
    }
    
    NSArray *courseToShow = self.dataSource.count > 5 ? [self.dataSource subarrayWithRange:NSMakeRange(0, 5)] : self.dataSource;
    
    MEHeaderView *headerView = [[MEHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 180)];
    [headerView updateContentWithCourses:courseToShow];
    headerView.delegate = self;
    self.tableView.tableHeaderView = headerView;
}

- (void)showPersonViewController:(UIBarButtonItem *)item {
    MEPersonViewController *personVC = [[MEPersonViewController alloc] init];
    [self.navigationController pushViewController:personVC animated:YES];
}

- (void)showUploadViewController:(UIBarButtonItem *)item {
    MEUploadedCourseVC *uploadedCourseVC = [[MEUploadedCourseVC alloc] init];
    [self.navigationController pushViewController:uploadedCourseVC animated:YES];
}

- (void)toShowCourseDetail:(MLObject *)courseGroupObj {
    MECourseDetailViewController *detailVC = [[MECourseDetailViewController alloc] init];
    detailVC.groupObj = courseGroupObj;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)cateButtonAction:(UIButton *)sender {
    NSInteger index = sender.tag - 3000;
    if (index >= 0 && index < self.courseCategories.count) {
        MLObject *cateObj = self.courseCategories[index];
        MECategoryDetailVC *categoryDetailVC = [[MECategoryDetailVC alloc] init];
        categoryDetailVC.cateObj = cateObj;
        [self.navigationController pushViewController:categoryDetailVC animated:YES];
    }
}

#pragma mark - setter & getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.rowHeight = 110.0f;
        [_tableView registerClass:[MEHomeCourseListCell class] forCellReuseIdentifier:kCellID];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"搜索课程";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIView *)cateButtonContainerViewWithFrame:(CGRect)frame {
    UIView *btnContainer = [[UIView alloc] initWithFrame:frame];
    btnContainer.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGFloat border = 15;
    CGFloat btnW = (width - border * 2) / 4;
    CGFloat btnH = (height - border * 2) / 2;
    
    for (NSInteger i = 0; i < self.courseCategories.count; i ++) {
        CGFloat btnX = (i % 4) * btnW + border;
        CGFloat btnY = (i / 4) * btnH + border;
        MLObject *cateObj = self.courseCategories[i];
        
        MECourseCateButton *cateBtn = [[MECourseCateButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        [cateBtn setTitle:cateObj[@"name"] forState:UIControlStateNormal];
        [cateBtn setTitleColor:UIColorFromRGBA(161, 163, 164, 1) forState:UIControlStateNormal];
        NSString *imgName = cateObj[@"iconName"];
        [cateBtn setImage:ImageNamed(imgName) forState:UIControlStateNormal];
        [cateBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(161, 163, 164, 0.2)] forState:UIControlStateHighlighted];
        cateBtn.tag = 3000 + i;
        [cateBtn addTarget:self action:@selector(cateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnContainer addSubview:cateBtn];
    }
    
    return btnContainer;
}

- (UIView *)sectionHeaderBottomViewWithFrame:(CGRect)frame {
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    UIView *topGrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 15)];
    topGrayView.backgroundColor = UIColorFromRGBA(242, 242, 242, 1);
    [containerView addSubview:topGrayView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, width, height - 15)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:bottomView];
    
    CGFloat labelH = 25;
    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(15, (height - 15 - 25) / 2, 3, labelH)];
    indicatorView.backgroundColor = UIColorFromRGBA(69, 200, 137, 1);
    [bottomView addSubview:indicatorView];
    
    CGFloat labelX = CGRectGetMaxX(indicatorView.frame) + 15;
    CGFloat labelW = width - labelX;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, (35 - 25) / 2, labelW, labelH)];
    titleLabel.text = @"课程列表";
    [bottomView addSubview:titleLabel];
    
    return containerView;
}
@end
