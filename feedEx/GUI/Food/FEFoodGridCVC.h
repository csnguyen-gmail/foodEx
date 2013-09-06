//
//  FEFoodGridCVC.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FESearchSettingInfo.h"

@interface FEFoodGridCVC : UICollectionViewController
- (void)updatePlacesWithSettingInfo:(FESearchPlaceSettingInfo *)placeSetting;
@end
