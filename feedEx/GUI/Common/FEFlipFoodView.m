//
//  FEFlipFoodView.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFlipFoodView.h"
#import "Photo.h"
#import "OriginPhoto.h"


@implementation FEFlipFoodView
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
        [bgView addSubview:label];
    }
    
    rect.size.height = 28;
    UIView *greyView = [[UIView alloc] initWithFrame:rect];
    greyView.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    [bgView addSubview:greyView];
    
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.text = self.name;
    nameLbl.frame = CGRectMake(13.0, 3.0, self.isBest ? 180 : 210, 21.0);
    [bgView addSubview:nameLbl];
    
    if (self.isBest) {
        UIImageView *isBestView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart_selected"]];
        CGRect heartRect = isBestView.frame;
        heartRect.origin.x = rect.size.width - heartRect.size.width - 3;
        isBestView.frame = heartRect;
        [bgView addSubview:isBestView];
    }
    return bgView;
}

@end
