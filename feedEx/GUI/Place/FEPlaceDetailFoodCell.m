//
//  FEPlaceDetailFoodCell.m
//  feedEx
//
//  Created by csnguyen on 7/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceDetailFoodCell.h"
#import "Photo.h"
#import <QuartzCore/QuartzCore.h>
#import "ThumbnailPhoto.h"
#import "AbstractInfo+Extension.h"

@implementation FEPlaceDetailFoodCell
- (void)awakeFromNib {
    self.backView.layer.cornerRadius = 10.0;
    self.backView.layer.masksToBounds = YES;
//    self.backView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.backView.layer.borderWidth = 1.5;

}
- (void)setFood:(Food *)food {
    _food = food;
    self.isBestImageView.hidden = ([food.isBest integerValue] != 1);
    if (self.food.photos.count != 0) {
        Photo *photo = [self.food firstPhoto];
        self.foodImageView.image = photo.thumbnailPhoto.image;
        self.noPhotoLbl.hidden = YES;
    }
    else {
        self.noPhotoLbl.hidden = NO;
    }
    
    if (self.foodNameTF.text.length != 0) {
        self.foodNameTF.text = food.name;
    }
}

@end
