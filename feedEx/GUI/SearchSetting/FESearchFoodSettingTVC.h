//
//  FESearchFoodSettingTVC.h
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FESearchSortBaseTVC.h"

@interface FESearchFoodSettingTVC : FESearchSortBaseTVC
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *costExprTF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bestSC;

@end