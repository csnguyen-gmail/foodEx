//
//  FEFlipGridFoodView.m
//  feedEx
//
//  Created by csnguyen on 8/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFlipGridFoodView.h"

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
    
    if (self.isLoading) {
        UILabel *label = [[UILabel alloc] initWithFrame:bgView.frame];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        label.text = @"Loading...";
        label.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:label];
    }
    else if (self.datasource.count != 0) {
        UIImage *image = self.datasource[index];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = bgView.frame;
        [bgView addSubview:imageView];
    }
    else {
        UILabel *label = [[UILabel alloc] initWithFrame:bgView.frame];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        label.text = @"No Photo";
        label.textAlignment = NSTextAlignmentCenter;
        [bgView addSubview:label];
    }
    
    rect.size.height = 24;
    UIView *greyView = [[UIView alloc] initWithFrame:rect];
    greyView.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    [bgView addSubview:greyView];
    
    UILabel *nameLbl = [[UILabel alloc] init];
    nameLbl.textColor = [UIColor whiteColor];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.adjustsFontSizeToFitWidth = YES;
    nameLbl.minimumScaleFactor = 0.5;
    nameLbl.text = self.name;
    nameLbl.frame = CGRectMake(6.0, 2.0, self.isBest ? 100.0 : 125.0, 21.0);
    [bgView addSubview:nameLbl];
    
    if (self.isBest) {
        UIImage *isBestImage = [UIImage imageNamed:@"heart_selected"];
        UIImageView *isBestImageView = [[UIImageView alloc] initWithImage:isBestImage];
        isBestImageView.frame = CGRectMake(113.0, 0.0, 25.0, 25.0);
        [bgView addSubview:isBestImageView];
    }
    
    UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    rect = detailBtn.frame;
    rect.origin = CGPointMake(118.0, 118.0);
    detailBtn.frame = rect;
    [detailBtn addTarget:self action:@selector(detailBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:detailBtn];
    
    if (self.isEditMode) {
        UIImage *selectedImage = [UIImage imageNamed:self.isSelected ? @"selected" : @"unselected"];
        UIImageView *selectedImageView = [[UIImageView alloc] initWithImage:selectedImage];
        rect = selectedImageView.frame;
        rect.origin = CGPointMake(3.0, 115.0);
        selectedImageView.frame = rect;
        [bgView addSubview:selectedImageView];
    }
    
    return bgView;
}
- (void)detailBtnTapped {
    [self.delegate didSelectDetailPlaceAtIndex:self.cellIndex];
}
@end
