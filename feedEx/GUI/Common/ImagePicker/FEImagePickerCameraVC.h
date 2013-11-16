//
//  FEImagePickerCameraVC.h
//  NewImagePicker
//
//  Created by csnguyen on 11/6/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FEImagePickerCameraVC;
@protocol FEImagePickerCameraDelegate <NSObject>
- (void)imagePickerCamera:(FEImagePickerCameraVC*)cameraVC didFinishWithImage:(UIImage*)image;
- (void)imagePickerCameraSwithToPhoto:(FEImagePickerCameraVC*)cameraVC;
@end

@interface FEImagePickerCameraVC : UIViewController
@property (nonatomic, weak) id<FEImagePickerCameraDelegate> delegate;
@end
