//
//  FESearchPlaceSettingTVC.m
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchPlaceSettingTVC.h"
#import "FEActionSheetPicker.h"
#import "CoredataCommon.h"

@interface FESearchPlaceSettingTVC ()
@end

@implementation FESearchPlaceSettingTVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ratingView setupBigStarEditable:YES];
}
#pragma mark - implement super functions
- (NSNumber *)tagType {
    return CD_TAG_PLACE;
}
- (NSArray*)getTypeStrings {
    return [PLACE_SORT_TYPE_STRING_DICT allKeys];
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
