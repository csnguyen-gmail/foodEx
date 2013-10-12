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
    
    if (self.datasource.count != 0) {
        Photo *photo = self.datasource[index];
        UIImage *image = [[UIImage alloc] initWithData:photo.originPhoto.imageData];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = bgView.frame;
        [bgView addSubview:imageView];
    }
    else {
        UILabel *label = [[UILabel alloc] initWithFrame:bgView.frame];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        label.text = @"No Photo";
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.2;
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    }

    rect.size.height = 27;
    UIView *greyView = [[UIView alloc] initWithFrame:rect];
    greyView.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    [bgView addSubview:greyView];
    // checked time
    UIImageView *emptyStarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star_empty"]];
    emptyStarView.frame =  CGRectOffset(emptyStarView.frame, 5.0, -2.0);
    [bgView addSubview:emptyStarView];
    UILabel *timesCheckLbl = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 11.0, 10.0, 9.0)];
    timesCheckLbl.textColor = [UIColor blackColor];
    timesCheckLbl.backgroundColor = [UIColor clearColor];
    timesCheckLbl.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    timesCheckLbl.textAlignment = NSTextAlignmentCenter;
    timesCheckLbl.font = [UIFont systemFontOfSize:12.0];
    timesCheckLbl.adjustsFontSizeToFitWidth = YES;
    timesCheckLbl.minimumScaleFactor = 0.2;
    timesCheckLbl.text = [NSString stringWithFormat:@"%d", self.timesCheckin];
    [bgView addSubview:timesCheckLbl];
    // rate
    DYRateView *ratingView = [[DYRateView alloc] initWithFrame:CGRectMake(self.frame.size.width - 68, 10.0, 66.0, 12.0)];
    ratingView.backgroundColor = [UIColor clearColor];
    ratingView.rate = self.rating;
    [bgView addSubview:ratingView];
    
    // name
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(36.0, 4.0, ratingView.frame.origin.x - 36, 21.0)];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.text = self.name;
    [bgView addSubview:nameLbl];
    
    return bgView;
}

@end
