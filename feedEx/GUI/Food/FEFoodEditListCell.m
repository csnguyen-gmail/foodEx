//
//  EFoodEditListCell.m
//  feedEx
//
//  Created by csnguyen on 7/14/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//
#import "Photo.h"
#import "FEFoodEditListCell.h"
#import "AbstractInfo+Extension.h"
#import "FECoreDataController.h"
@interface FEFoodEditListCell()<UITextFieldDelegate, FEDynamicScrollViewDelegate>
@property (weak, nonatomic) FECoreDataController * coreData;
@end

@implementation FEFoodEditListCell
- (void)awakeFromNib {
    self.nameTF.delegate = self;
    self.nameTF.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    self.foodsScrollView.dynamicScrollViewDelegate = self;

}
#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}

- (void)setFood:(Food *)food {
    _food = food;
    self.isBestButton.selected = [food.isBest boolValue];
    self.nameTF.text = food.name;
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (Photo *photo in self.food.photos) {
        [photos addObject:photo.thumbnailPhoto];
    }
    [self setupFoodsScrollViewWithArrayOfThumbnailImages:photos];
}
#pragma mark - event handler
- (IBAction)isBestButtonTapped:(UIButton *)sender {
    self.isBestButton.selected = !self.isBestButton.selected;
    self.food.isBest = @(self.isBestButton.selected);
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.food.name = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Photos
- (void)enterDraggingMode {
    [self.delegate enterDraggingMode];
}
- (void)exitDraggingMode {
    [self.delegate exitDraggingMode];
}
- (void)enterEditMode {
    self.photoButton.selected = YES;
}
- (void)exitEditMode {
    self.photoButton.selected = NO;
    self.foodsScrollView.editMode = NO;
}
- (IBAction)photoButtonTapped:(UIButton *)sender {
    if (self.photoButton.selected) {
        [self exitEditMode];
    }
    else {
        [self.delegate selectImageAtCell:self];
    }
}
- (void)setupFoodsScrollViewWithArrayOfThumbnailImages:(NSArray *)thumbnailImages {
    for (UIImage *thumbnailImage in thumbnailImages) {
        FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                               deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
        [self.foodsScrollView addView:wiggleView atIndex:self.foodsScrollView.wiggleViews.count];
    }
}
- (void)removeImageAtIndex:(NSUInteger)index {
    [self.food removePhotoAtIndex:index];
}
- (void)viewMovedFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [self.food movePhotoFromIndex:fromIndex toIndex:toIndex];
}
- (void)addNewThumbnailImage:(UIImage *)thumbnailImage andOriginImage:(UIImage *)originImage {
    FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                           deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
    [self.foodsScrollView addView:wiggleView atIndex:0];
    [self.food insertPhotoWithThumbnail:thumbnailImage andOriginImage:originImage atIndex:0];
}

@end
