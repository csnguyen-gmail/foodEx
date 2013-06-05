//
//  UIImage+Extension.h
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define THUMBNAIL_WIDTH 64
#define THUMBNAIL_HEIGHT 64
#define THUMBNAIL_SIZE CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)

@interface UIImage (Extension)
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
