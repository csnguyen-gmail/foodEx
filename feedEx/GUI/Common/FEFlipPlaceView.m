//
//  FEFlipPlaceView.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFlipPlaceView.h"
#import "Photo.h"
#import "DYRateView.h"
#import "OriginPhoto.h"

@implementation FEFlipPlaceView
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
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 2.0, 151.0, 21.0)];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.text = self.name;
    
    DYRateView *ratingView = [[DYRateView alloc] initWithFrame:CGRectMake(169.0, 6.0, 66.0, 12.0)];
    ratingView.backgroundColor = [UIColor clearColor];
    ratingView.rate = self.rating;
    
    [bgView addSubview:imageView];
    [bgView addSubview:greyView];
    [bgView addSubview:nameLbl];
    [bgView addSubview:ratingView];
    return bgView;
}

@end
