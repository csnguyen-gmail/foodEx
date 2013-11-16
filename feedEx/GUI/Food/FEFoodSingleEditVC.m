//
//  FEFoodSingleEditVC.m
//  feedEx
//
//  Created by csnguyen on 10/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodSingleEditVC.h"
#import "Photo.h"
#import "AbstractInfo+Extension.h"
#import "ThumbnailPhoto.h"
#import <QuartzCore/QuartzCore.h>
#import "FEImagePicker.h"
#import "Common.h"
#import "FECoreDataController.h"

@interface FEFoodSingleEditVC ()<FEDynamicScrollViewDelegate, FEImagePickerDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *highlightView;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *foodsScrollView;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *isBestButton;
@property (strong, nonatomic) FEImagePicker *imagePicker;
@property (weak, nonatomic) FECoreDataController * coreData;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@end

@implementation FEFoodSingleEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
	self.foodsScrollView.dynamicScrollViewDelegate = self;
    self.highlightView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    self.bgView.layer.cornerRadius = 10.0;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.bgView.layer.borderWidth = 1.5;
    // build GUI
    self.isBestButton.selected = [self.food.isBest boolValue];
    self.nameTF.text = self.food.name;
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (Photo *photo in self.food.photos) {
        [photos addObject:photo.thumbnailPhoto.image];
    }
    [self setupFoodsScrollViewWithArrayOfThumbnailImages:photos];

}
- (void)close {
    [UIView transitionWithView:self.parentViewController.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.view removeFromSuperview];
                    } completion:^(BOOL finished) {
                        [self removeFromParentViewController];
                    }];
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
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}

#pragma mark -handler
#define ALERT_TAG_DONE      1002
- (IBAction)closeTapped:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Edit Food Confirmation"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save & Exit", @"Exit", nil];
    alertView.tag = ALERT_TAG_DONE;
    [alertView show];
}
- (IBAction)photoButtonTapped:(UIButton *)sender {
    if (self.photoButton.selected) {
        [self exitEditMode];
    } else {
        [self.imagePicker startPickupWithParentViewController:self];
    }
}
- (IBAction)isBestButtonTapped:(UIButton *)sender {
    self.isBestButton.selected = !self.isBestButton.selected;
    self.food.isBest = @(self.isBestButton.selected);
}
#pragma mark - Photos
- (void)exitEditMode {
    self.photoButton.selected = NO;
    self.foodsScrollView.editMode = NO;
}
# pragma mark - FEImagePickerDelegate
- (FEImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[FEImagePicker alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}
- (void)imagePickerDidFinishWithImage:(UIImage *)image {
    if (image) {
        UIImage *thumbnailImage = [UIImage imageWithImage:image
                                             scaledToSize:THUMBNAIL_SIZE];
        [self addNewThumbnailImage:thumbnailImage andOriginImage:image];
    }
}

#pragma mark - FEDynamicScrollViewDelegate
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
#pragma mark - Alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_TAG_DONE) {
        switch (buttonIndex) {
            case 1:
            {
                [self.indicatorView startAnimating];
                [self.coreData saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
                    [self.indicatorView stopAnimating];
                    [self close];
                }];
            }
                break;
            case 2:
            {
                [self.indicatorView startAnimating];
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [queue addOperationWithBlock:^{
                    [self.coreData.managedObjectContext rollback];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.indicatorView stopAnimating];
                        [self close];
                    }];
                }];
            }
                break;
            default:
                break;
        }
    }
}
@end
