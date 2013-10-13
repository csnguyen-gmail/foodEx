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
#import "ThumbnailPhoto.h"
@interface FEFoodEditListCell()<UITextFieldDelegate, FEDynamicScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *highlightView;
@end

@implementation FEFoodEditListCell
- (void)awakeFromNib {
    self.nameTF.delegate = self;
    self.foodsScrollView.dynamicScrollViewDelegate = self;
    self.highlightView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
}
- (void)setupFoodsScrollViewWithArrayOfThumbnailImages:(NSArray *)thumbnailImages {
    NSMutableArray *wiggles = [NSMutableArray array];
    for (UIImage *thumbnailImage in thumbnailImages) {
        FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                               deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
        [wiggles addObject:wiggleView];
    }
    [self.foodsScrollView setupWithWiggleArray:wiggles withAnimation:NO];
}
#pragma mark - getter setter
- (void)setFood:(Food *)food {
    _food = food;
    self.isBestButton.selected = [food.isBest boolValue];
    self.nameTF.text = food.name;
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (Photo *photo in self.food.photos) {
        [photos addObject:photo.thumbnailPhoto.image];
    }
    [self setupFoodsScrollViewWithArrayOfThumbnailImages:photos];
}
#pragma mark - event handler
- (IBAction)isBestButtonTapped:(UIButton *)sender {
    self.isBestButton.selected = !self.isBestButton.selected;
    self.food.isBest = @(self.isBestButton.selected);
}
- (IBAction)photoButtonTapped:(UIButton *)sender {
    if (self.photoButton.selected) {
        [self exitEditMode];
    }
    else {
        [self.delegate selectImageAtCell:self];
    }
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate cellDidBeginEditing:self];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.food.name = textField.text;
    [self.delegate cellDidEndEditing:self];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Photos
- (void)exitEditMode {
    self.photoButton.selected = NO;
    self.foodsScrollView.editMode = NO;
}
#pragma mark - FEDynamicScrollViewDelegate
- (void)enterDraggingMode {
    [self.delegate enterDraggingMode];
}
- (void)exitDraggingMode {
    [self.delegate exitDraggingMode];
}
- (void)enterEditMode {
    self.photoButton.selected = YES;
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
    [self.foodsScrollView addView:wiggleView atIndex:0 withAnimation:YES];
    [self.food insertPhotoWithThumbnail:thumbnailImage andOriginImage:originImage atIndex:0];
}

@end
