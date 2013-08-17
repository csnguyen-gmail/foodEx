//
//  UIImage+Extension.m
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)
+ (void)beginImageContextWithSize:(CGSize)size opaque:(BOOL)opaque{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, opaque, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
}
+ (void)endImageContext {
    UIGraphicsEndImageContext();
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    [self beginImageContextWithSize:newSize opaque:YES];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return newImage;
}
@end
