//
//  FEImagePickerScrollView.h
//  NewImagePicker
//
//  Created by csnguyen on 11/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEImagePickerScrollView : UIScrollView
- (void)displayImage:(UIImage *)image;
- (UIImage*)croppedImage;
@end
