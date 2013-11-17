//
//  FEFoodGridCVC.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FESearchSettingInfo.h"

@protocol FEFoodGridTVCDelegate <NSObject>
- (void)didSelectFoodItem;
@end

@interface FEFoodGridCVC : UICollectionViewController
@property (nonatomic) BOOL isEditMode;
@property (nonatomic, weak) id<FEFoodGridTVCDelegate> foodGridDelegate;
- (void)updateFoodsWithSettingInfo:(FESearchFoodSettingInfo *)foodSetting;
@property (strong, nonatomic) NSString *quickSearchString;
- (NSArray*)getSelectedFoods;
@end
