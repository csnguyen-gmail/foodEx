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
#import "DYRateView.h"

@implementation FEFlipGridFoodView
// overwrite super class
- (void)setCurrentViewIndex:(NSUInteger)currentViewIndex {
    super.currentViewIndex = currentViewIndex;
    [self.delegate didChangeCurrentIndex:currentViewIndex atRow:self.rowIndex];
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
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 2.0, 74.0, 21.0)];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.adjustsFontSizeToFitWidth = YES;
    nameLbl.minimumScaleFactor = 0.5;
    nameLbl.text = self.name;
    
    DYRateView *ratingView = [[DYRateView alloc] initWithFrame:CGRectMake(77.0, 7.0, 66.0, 12.0)];
    ratingView.backgroundColor = [UIColor clearColor];
    
    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGRect frame = detailBtn.frame;
    frame.origin = CGPointMake(118.0, 118.0);
    detailBtn.frame = frame;
    [detailBtn addTarget:self action:@selector(detailBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    
    ratingView.rate = self.rating;
    [bgView addSubview:imageView];
    [bgView addSubview:greyView];
    [bgView addSubview:nameLbl];
    [bgView addSubview:ratingView];
    [bgView addSubview:detailBtn];
    return bgView;
}
- (void)detailBtnTapped {
    [self.delegate didSelectPlaceAtRow:self.rowIndex];
}
@end
