//
//  FESearchFoodSettingTVC.m
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchFoodSettingTVC.h"
#import "CoredataCommon.h"

@interface FESearchFoodSettingTVC ()

@end

@implementation FESearchFoodSettingTVC
- (NSNumber *)tagType {
    return CD_TAG_FOOD;
}
- (NSArray *)getTypeStrings {
    return [FOOD_SORT_TYPE_STRING_DICT allKeys];
}
- (IBAction)firstSortTapped:(UITextField *)sender{
    [super firstSortTapped:sender];
}
- (IBAction)secondSortTapped:(UITextField *)sender{
    [super secondSortTapped:sender];
}
- (IBAction)tagsTapped:(UITextField *)sender{
    [super tagsTapped:sender];
}

@end
