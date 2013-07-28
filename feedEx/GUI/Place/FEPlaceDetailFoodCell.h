//
//  FEPlaceDetailFoodCell.h
//  feedEx
//
//  Created by csnguyen on 7/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Food.h"

@interface FEPlaceDetailFoodCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UIImageView *isBestImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodNameTF;

@property (strong, nonatomic) Food *food;
@end
