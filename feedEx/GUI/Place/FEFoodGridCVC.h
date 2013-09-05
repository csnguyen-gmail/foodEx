//
//  FEFoodGridCVC.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEPlaceDataSource.h"

@interface FEFoodGridCVC : UICollectionViewController
@property (strong, nonatomic) FEPlaceDataSource *placeDataSource;
@end
