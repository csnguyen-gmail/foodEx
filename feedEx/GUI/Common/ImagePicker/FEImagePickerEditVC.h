//
//  FEImagePickerEditVC.h
//  NewImagePicker
//
//  Created by csnguyen on 11/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FEImagePickerEditVC;

@protocol FEImagePickerEditDelegate <NSObject>
- (void)imagePickerEdit:(FEImagePickerEditVC*)editVC didFinishWithImage:(UIImage*)image;
- (void)imagePickerEditRetake:(FEImagePickerEditVC*)editVC;
@end

@interface FEImagePickerEditVC : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<FEImagePickerEditDelegate> delegate;
@end
