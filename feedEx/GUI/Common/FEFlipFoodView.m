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
    
    Photo *photo = self.datasource[index];
    UIImage *image = [[UIImage alloc] initWithData:photo.originPhoto.imageData];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = bgView.frame;
    
    rect.size.height = 28;
    UIView *greyView = [[UIView alloc] initWithFrame:rect];
    greyView.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 3.0, 200.0, 21.0)];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.text = self.name;
    
    UIImageView *isBestView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart_selected"]];
    CGRect heartRect = isBestView.frame;
    heartRect.origin.x = rect.size.width - heartRect.size.width - 3;
    isBestView.frame = heartRect;
    
    [bgView addSubview:imageView];
    [bgView addSubview:greyView];
    [bgView addSubview:nameLbl];
    [bgView addSubview:isBestView];
    return bgView;
}

@end
