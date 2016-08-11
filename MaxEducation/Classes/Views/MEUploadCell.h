//
//  MEUploadTextFieldCell.h
//  MaxEducation
//
//  Created by luomeng on 16/6/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UploadCellTypeTextField,
    UploadCellTypeTextView,
    UploadCellTypeImageView,
    UploadCellTypeLabel,
} UploadCellType;

@class MEUploadCell;

@protocol MEUploadCellProtocol <NSObject>
- (void)beginEditingTextField:(UIView *)editingView;
- (void)didEndEditingText:(MEUploadCell *)cell;
@end

@interface MEUploadCell : UITableViewCell
@property (nonatomic, weak) id<MEUploadCellProtocol> delegate;
@property (nonatomic, copy) dispatch_block_t addImageBlock;

- (void)configCellWithTitle:(NSString *)title content:(NSString *)content placeHolder:(NSString *)placeHolder forCellType:(UploadCellType)type limitCount:(NSInteger)limitCount;

- (void)updateCourseImage:(UIImage *)img;
- (void)updateLabelContent:(NSString *)txt;

- (NSString *)textFieldInputContent;

@end
