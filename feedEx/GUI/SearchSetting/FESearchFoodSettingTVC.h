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
@property (weak, nonatomic) NSNumber *tagType;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *tagsTF;
@property (weak, nonatomic) IBOutlet UITextField *costExprTF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *bestSC;
@property (weak, nonatomic) IBOutlet UITextField *firstSortTF;
@property (weak, nonatomic) IBOutlet UITextField *secondSortTF;
- (IBAction)firstSortTapped:(UITextField *)sender;
- (IBAction)secondSortTapped:(UITextField *)sender;
- (IBAction)tagsTapped:(UITextField *)sender;
@end
