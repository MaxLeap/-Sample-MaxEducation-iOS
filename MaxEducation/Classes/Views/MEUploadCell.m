//
//  MEUploadTextFieldCell.m
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MEUploadCell.h"
#import "UITextView+Placeholder.h"

@interface MEUploadCell () <UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *courseImgView;
@property (nonatomic, strong) UIImageView *indicatorView;
@property (nonatomic, assign) UploadCellType type;
@property (nonatomic, assign) NSInteger limitCount;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation MEUploadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    self.titleL = [[UILabel alloc] init];
    
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    
    self.contentLabel = [[UILabel alloc] init];
    self.courseImgView = [[UIImageView alloc] init];
    self.indicatorView = [[UIImageView alloc] init];
    
    self.indicatorView.image = ImageNamed(@"icn_more");
    self.courseImgView.image = ImageNamed(@"icn_addimg");
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImageAction:)];
    self.courseImgView.userInteractionEnabled = YES;
    [self.courseImgView addGestureRecognizer:tapGesture];
    
    [self.contentView addSubview:self.titleL];
    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.textView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.courseImgView];
    [self.contentView addSubview:self.indicatorView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    self.titleL.frame = CGRectMake(10, 0, 75, height);
    CGFloat fieldX = CGRectGetMaxX(self.titleL.frame) + 3;
    CGFloat fieldW = width - fieldX;
    self.textField.frame = CGRectMake(fieldX, 0, fieldW, height);
    
    self.textView.frame = CGRectMake(fieldX, 5, fieldW, height - 5*2);
    
    CGFloat indicatorW = 25;
    CGFloat indicatorX = width - 10 - indicatorW;
    CGFloat indicatorY = (height - indicatorW) / 2;
    self.indicatorView.frame = CGRectMake(indicatorX, indicatorY, indicatorW, indicatorW);
    
    CGFloat contentLabelW = width - fieldX - CGRectGetWidth(self.indicatorView.frame) - 15;
    self.contentLabel.frame = CGRectMake(fieldX, 0, contentLabelW, height);
    
    CGFloat imgW = 70;
    CGFloat imgY = (height - 70) / 2;
    self.courseImgView.frame = CGRectMake(fieldX, imgY, imgW, imgW);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.addImageBlock = nil;
    
    self.titleL.hidden = NO;
    self.textField.hidden = NO;
    self.textView.hidden = NO;
    self.indicatorView.hidden = NO;
    self.contentLabel.hidden = NO;
    self.courseImgView.hidden = NO;
}

- (void)configCellWithTitle:(NSString *)title content:(NSString *)content placeHolder:(NSString *)placeHolder forCellType:(UploadCellType)type limitCount:(NSInteger)limitCount {

    self.type = type;
    self.limitCount = limitCount;
    
    self.titleL.text = title;
    if (type == UploadCellTypeTextField) {
        self.indicatorView.hidden = YES;
        self.contentLabel.hidden = YES;
        self.courseImgView.hidden = YES;
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        
        self.textField.placeholder = placeHolder;
        self.textField.text = content;
    } else if (type == UploadCellTypeTextView) {
        self.indicatorView.hidden = YES;
        self.contentLabel.hidden = YES;
        self.courseImgView.hidden = YES;
        self.textView.hidden = NO;
        self.textField.hidden = YES;
        
        self.textView.text = content;
        self.textView.placeholder = placeHolder;
    } else if (type == UploadCellTypeImageView) {
        self.textField.hidden = YES;
        self.indicatorView.hidden = YES;
        self.contentLabel.hidden = YES;
        self.textField.hidden = YES;
        self.textView.hidden = YES;
        
        if (content.length) {
            NSURL *imgURL = [NSURL URLWithString:content];
            [self.courseImgView sd_setImageWithURL:imgURL placeholderImage:ImageNamed(@"icn_addimg")];            
        }
    } else {
        self.textField.hidden = YES;
        self.courseImgView.hidden = YES;
        self.textView.hidden = YES;
        
        [self updateLabelContent:content];
    }
}

- (void)updateCourseImage:(UIImage *)img {
    if (self.type == UploadCellTypeImageView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.courseImgView.image = img;
        });
    }
}

- (void)updateLabelContent:(NSString *)txt {
    if (self.type == UploadCellTypeLabel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentLabel.text = txt;
        });
    }
}

- (NSString *)textFieldInputContent {
    if (self.type == UploadCellTypeTextField) {
        return self.textField.text;
    } else if (self.type == UploadCellTypeLabel) {
        return self.contentLabel.text;
    } else if (self.type == UploadCellTypeTextView) {
        return self.textView.text;
    } else {
        return @"";
    }
}

- (void)addImageAction:(UITapGestureRecognizer *)gesture {
    NSLog(@"add image action");
    if (self.addImageBlock) {
        self.addImageBlock();
    }
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(beginEditingTextField:)]) {
        [self.delegate beginEditingTextField:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textField.text = %@", textField.text);
    if ([self.delegate respondsToSelector:@selector(didEndEditingText:)]) {
        [self.delegate didEndEditingText:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *fieldTxt = textField.text;
    if (fieldTxt.length >= self.limitCount && string.length > 0) {
        textField.textColor = [UIColor redColor];
        return NO;
    }
    textField.textColor = [UIColor blackColor];
    return YES;
}

#pragma mark - UITextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(beginEditingTextField:)]) {
        [self.delegate beginEditingTextField:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textField.text = %@", textView.text);
    if ([self.delegate respondsToSelector:@selector(didEndEditingText:)]) {
        [self.delegate didEndEditingText:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *preTxt = textView.text;
    if (preTxt.length >= self.limitCount && text.length > 0) {
        textView.textColor = [UIColor redColor];
        return NO;
    }
    textView.textColor = [UIColor blackColor];
    return YES;
}

@end
