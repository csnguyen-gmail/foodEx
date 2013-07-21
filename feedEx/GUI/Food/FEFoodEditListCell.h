//
//  EFoodEditListCell.h
//  feedEx
//
//  Created by csnguyen on 7/14/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEDynamicScrollView.h"
#import "Food.h"
@class FEFoodEditListCell;
@protocol FEFoodEditListCellDelegate <NSObject>
- (void)enterDraggingMode;
- (void)exitDraggingMode;
- (void)selectImageAtCell:(FEFoodEditListCell*)cell;
- (void)cellDidBeginEditing:(UITableViewCell *)cell;
- (void)cellDidEndEditing:(UITableViewCell *)cell;
@end

@interface FEFoodEditListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *foodsScrollView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *isBestButton;
@property (weak, nonatomic) id<FEFoodEditListCellDelegate> delegate;

@property (strong, nonatomic) Food *food;
- (void)addNewThumbnailImage:(UIImage *)thumbnailImage andOriginImage:(UIImage *)originImage;
@end
