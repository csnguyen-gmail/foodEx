//
//  FEImagePickerScrollView.m
//  NewImagePicker
//
//  Created by csnguyen on 11/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerScrollView.h"
@interface FEImagePickerScrollView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *zoomExView;  // contains the full image
@property CGSize imageSize;
@property CGPoint pointToCenterAfterResize;
@property CGFloat scaleToRestoreAfterResize;

@end

@implementation FEImagePickerScrollView
- (void)awakeFromNib {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
}

- (void)layoutSubviews  {
    
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomExView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _zoomExView.frame = frameToCenter;
}

- (UIImage *)croppedImage {
    UIImage *sourceImage = self.zoomExView.image;
    UIImage *newImage = nil;
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointMake(-self.contentOffset.x, -self.contentOffset.y);
    thumbnailRect.size.width  = sourceImage.size.width * self.zoomScale;
    thumbnailRect.size.height = sourceImage.size.height * self.zoomScale;
    
    [UIImage beginImageContextWithSize:CGSizeMake(320.0, 320.0) opaque:YES];
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) {
        NSLog(@"could not scale image");
    }
    [UIImage endImageContext];
    
    return newImage;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return _zoomExView;
}


#pragma mark - Configure scrollView to display new image

- (void)displayImage:(UIImage *)image {
    
    // clear the previous image
    [_zoomExView removeFromSuperview];
    _zoomExView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    _zoomExView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_zoomExView];
    
    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize {
    
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setInitPosition];
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    CGFloat minScale = MAX(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = self.minimumZoomScale;
}

- (void)setInitPosition {
    CGPoint point;
    point.x = (self.contentSize.width - self.bounds.size.width) / 2;
    point.y = (self.contentSize.height - self.bounds.size.height) / 2;
    self.contentOffset = point;
}
@end
