//
//  FEFlipPhotosView.m
//  feedEx
//
//  Created by csnguyen on 7/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFlipPhotosView.h"
#import "Photo.h"
#import "FERoundImageView.h"
#import "OriginPhoto.h"
#import "ThumbnailPhoto.h"

@implementation FEFlipPhotosView
// overwrite super class
- (void)setCurrentViewIndex:(NSUInteger)currentViewIndex {
    super.currentViewIndex = currentViewIndex;
    [self.delegate didChangeCurrentIndex:currentViewIndex atRow:self.rowIndex];
}
#define NO_PHOTO_PADDING 4
- (UIView *)getViewAtIndex:(NSUInteger)index {
    if (self.datasource.count != 0) {
        Photo *photo = self.datasource[index];
        UIImage *image = self.usingThumbnail ? photo.thumbnailPhoto.image : [[UIImage alloc] initWithData:photo.originPhoto.imageData];
        FERoundImageView *imageView = [[FERoundImageView alloc] initWithImage:image];
        return imageView;
    }
    else {
        UIView *bgView = [[UIView alloc] initWithFrame:
                          CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.width)];
        bgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        
        UILabel *label = [[UILabel alloc] initWithFrame:
                          CGRectMake(NO_PHOTO_PADDING, 0.0, self.frame.size.width - NO_PHOTO_PADDING * 2, self.frame.size.height)];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"No Photo";
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.2;
        label.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:label];
        return bgView;
    }

}

@end
