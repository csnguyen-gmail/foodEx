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
#pragma mark - implement super functions
- (NSNumber *)tagType {
    return CD_TAG_PLACE;
}
- (NSArray*)getTypeStrings {
    return @[@"Name", @"Rating", @"Most visited", @"Created date"];
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
