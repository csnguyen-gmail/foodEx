//
//  UIImage+Extension.h
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImage (Extension)
+ (void)beginImageContextWithSize:(CGSize)size opaque:(BOOL)opaque;
+ (void)endImageContext;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image resizeAndCropAutoFitCenterForSize:(CGSize)targetSize;
@end
