//
//  FESearchPlaceSettingTVC.m
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchPlaceSettingTVC.h"
#import "FEActionSheetPicker.h"

@interface FESearchPlaceSettingTVC ()
@end

@implementation FESearchPlaceSettingTVC
#pragma mark - implement super functions
- (NSArray*)getTypeStrings {
    return @[@"Name", @"Rating", @"Most visited", @"Created date"];
}
@end
