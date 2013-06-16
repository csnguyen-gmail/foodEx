//
//  FEEditPlaceInfoTVC.h
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEDynamicScrollView.h"
#import "GKImagePicker.h"
#import "FETagTextView.h"
#import "CPTextViewPlaceholder.h"
#import "DYRateView.h"

@protocol FEEditPlaceInfoTVCDelegate <NSObject>
// Dynamic scroll view
- (void)addNewThumbnailImage:(UIImage*)thumbnailImage andOriginImage:(UIImage*)originImage;
- (void)removeImageAtIndex:(NSUInteger)index;

@end
@interface FEEditPlaceInfoTVC : UITableViewController<FEDynamicScrollViewDelegate, UITextFieldDelegate, GKImagePickerDelegate>
@property (weak, nonatomic) id<FEEditPlaceInfoTVCDelegate> editPlaceTVCDelegate;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet DYRateView *ratingView;
@property (weak, nonatomic) IBOutlet FETagTextView *tagTextView;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) NSArray *tags; // array of NSString

- (void) setupPhotoScrollViewWithArrayOfThumbnailImages:(NSArray*)thumbnailImages;
@end
