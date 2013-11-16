//
//  FEImagePickerPhotoVC.h
//  NewImagePicker
//
//  Created by csnguyen on 11/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FEImagePickerPhotoVC;
@protocol FEImagePickerPhotoDelegate <NSObject>
- (void)imagePickerPhoto:(FEImagePickerPhotoVC*)photoVC didFinishWithImage:(UIImage*)image;
- (void)imagePickerPhotoSwithToCamera:(FEImagePickerPhotoVC*)photoVC;
@end

@interface FEImagePickerPhotoVC : UIViewController
@property (nonatomic, weak) id<FEImagePickerPhotoDelegate> delegate;
@end
