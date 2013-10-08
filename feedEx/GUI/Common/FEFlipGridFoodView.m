//
//  FEFlipGridFoodView.m
//  feedEx
//
//  Created by csnguyen on 8/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFlipGridFoodView.h"
#import "Photo.h"
#import "OriginPhoto.h"

@implementation FEFlipGridFoodView
// overwrite super class
- (void)setCurrentViewIndex:(NSUInteger)currentViewIndex {
    super.currentViewIndex = currentViewIndex;
    [self.delegate didChangeCurrentIndex:currentViewIndex atRow:self.cellIndex];
}
- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    // in case edit mode, transfer select event to parent
    if (self.isEditMode) {
        [self.delegate didSelectCellAtIndex:self.cellIndex];
    }
    else {
        [super handleTapFrom:recognizer];
    }
}

- (UIView *)getViewAtIndex:(NSUInteger)index {
    CGRect rect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    UIView *bgView = [[UIView alloc] initWithFrame:rect];
    bgView.layer.cornerRadius = 10;
    bgView.layer.masksToBounds = YES;
    
    Photo *photo = self.datasource[index];
    UIImage *image = [[UIImage alloc] initWithData:photo.originPhoto.imageData];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = bgView.frame;
    
    rect.size.height = 24;
    UIView *greyView = [[UIView alloc] initWithFrame:rect];
    greyView.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.adjustsFontSizeToFitWidth = YES;
    nameLbl.minimumScaleFactor = 0.5;
    nameLbl.text = self.name;
    nameLbl.frame = CGRectMake(6.0, 2.0, self.isBest ? 100.0 : 125.0, 21.0);
    
    UIImageView *isBestImageView;
    if (self.isBest) {
        UIImage *isBestImage = [UIImage imageNamed:@"heart_selected"];
        isBestImageView = [[UIImageView alloc] initWithImage:isBestImage];
        isBestImageView.frame = CGRectMake(113.0, 0.0, 25.0, 25.0);
    }
    
    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    rect = detailBtn.frame;
    rect.origin = CGPointMake(118.0, 118.0);
    detailBtn.frame = rect;
    [detailBtn addTarget:self action:@selector(detailBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *selectedImageView;
    if (self.isEditMode) {
        UIImage *selectedImage = [UIImage imageNamed:self.isSelected ? @"selected" : @"unselected"];
        selectedImageView = [[UIImageView alloc] initWithImage:selectedImage];
        rect = selectedImageView.frame;
        rect.origin = CGPointMake(3.0, 115.0);
        selectedImageView.frame = rect;
    }
    
    [bgView addSubview:imageView];
    [bgView addSubview:greyView];
    [bgView addSubview:nameLbl];
    if (self.isBest) {
        [bgView addSubview:isBestImageView];
    }
    if (self.isEditMode) {
        [bgView addSubview:selectedImageView];
    }
    [bgView addSubview:detailBtn];
    return bgView;
}
- (void)detailBtnTapped {
    [self.delegate didSelectDetailPlaceAtIndex:self.cellIndex];
}
@end
