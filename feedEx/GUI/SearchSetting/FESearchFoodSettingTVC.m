//
//  FESearchFoodSettingTVC.m
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchFoodSettingTVC.h"

@interface FESearchFoodSettingTVC ()

@end

@implementation FESearchFoodSettingTVC

- (NSArray *)getTypeStrings {
    return @[@"Name", @"Cost", @"Created date"];
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
