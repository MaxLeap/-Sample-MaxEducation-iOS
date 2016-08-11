//
//  MEWriteCommentVC.m
//  MaxEducation
//
//  Created by luomeng on 16/6/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEWriteCommentVC.h"
#import "UITextView+Placeholder.h"

@interface MEWriteCommentVC ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation MEWriteCommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"发表评论";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(publishComment:)];
    rightItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.textView];
}

#pragma mark - actions
- (void)publishComment:(UIBarButtonItem *)item {
    NSString *content = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"说的什么吧"];
        return;
    }
    
    MLObject *commentObj = [MLObject objectWithClassName:@"MEComment"];
    commentObj[@"belongToCourseID"] = self.courseGroupObj.objectId;
    commentObj[@"content"] = content;
    commentObj[@"commenter"] = [MLUser currentUser];
    
    [SVProgressHUD showWithStatus:@"发表中..."];
    [commentObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"发表成功！"];
            
            if ([self.delegate respondsToSelector:@selector(didPublishedComment)]) {
                [self.delegate didPublishedComment];
            }
            
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"发表失败，稍后再试!"];
        }
    }];
}

#pragma mark - setters & getters
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 280)];
        _textView.placeholder = @"说点什么吧.";
        _textView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _textView;
}

@end
