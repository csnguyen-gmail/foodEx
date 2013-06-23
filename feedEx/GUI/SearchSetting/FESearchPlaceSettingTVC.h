//
//  FESearchPlaceSettingTVC.h
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#define SEPARATED_STR  @"-"
#define SORT_STRING_FORMAT  @"%@-%@"
@interface FESearchPlaceSettingTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet DYRateView *ratingView;
@property (weak, nonatomic) IBOutlet UITextField *firstSortTF;
@property (weak, nonatomic) IBOutlet UITextField *secondSortTF;
- (void)setFirstSortText:(NSString*)firstSort andSecondSortText:(NSString*)secondSort;
@end
