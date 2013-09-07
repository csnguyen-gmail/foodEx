//
//  FEFoodGridCell.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEFlipGridFoodView.h"
#import "Place.h"

@interface FEFoodGridCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet FEFlipGridFoodView *flipFoodGridView;
@end
