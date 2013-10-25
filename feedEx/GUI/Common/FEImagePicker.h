//
//  FEImagePicker.h
//  TestCamera
//
//  Created by csnguyen on 10/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEImagePickerController.h"

@class FEImagePicker;

@protocol FEImagePickerDelegate <NSObject>
@optional
- (void)imagePicker:(FEImagePicker *)imagePicker pickedImage:(UIImage *)image;
- (void)imagePickerCancel;
@end

@interface FEImagePicker : NSObject
@property (nonatomic, strong) FEImagePickerController *imagePickerController;
@property (nonatomic, assign) CGSize cropSize; //default value is 320x320 (which is exactly the same as the normal imagepicker uses)
@property (nonatomic, assign) BOOL resizeableCropArea;
@property (nonatomic, weak) id<FEImagePickerDelegate> delegate;
-(void)startPickerFrom:(UIViewController*)parentVC;
@end
