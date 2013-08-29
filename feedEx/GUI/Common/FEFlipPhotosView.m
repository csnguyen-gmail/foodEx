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

@implementation FEFlipPhotosView
// overwrite super class
- (void)setCurrentViewIndex:(NSUInteger)currentViewIndex {
    super.currentViewIndex = currentViewIndex;
    [self.delegate didChangeCurrentIndex:currentViewIndex atRow:self.rowIndex];
}
- (UIView *)getViewAtIndex:(NSUInteger)index {
    Photo *photo = self.datasource[index];
    UIImage *image = self.usingThumbnail ? photo.thumbnailPhoto : [[UIImage alloc] initWithData:photo.originPhoto.imageData];
    FERoundImageView *imageView = [[FERoundImageView alloc] initWithImage:image];
    return imageView;
}

@end
