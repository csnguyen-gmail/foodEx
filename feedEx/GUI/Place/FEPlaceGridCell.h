//
//  FEPlaceGridCell.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEFlipGridPlaceView.h"
#import "Place.h"

@interface FEPlaceGridCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet FEFlipGridPlaceView *flipPlaceGridView;
@end
