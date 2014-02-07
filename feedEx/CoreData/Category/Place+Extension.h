//
//  Place+Extension.h
//  feedEx
//
//  Created by csnguyen on 7/18/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place.h"
#import "Food.h"
#import "FESearchSettingInfo.h"
#import "FEMapSearchSettingVC.h"
#import <CoreLocation/CoreLocation.h>

@interface Place (Extension)
// Change to None Order Set
//- (void)insertFoodsAtIndex:(NSUInteger)index;
//- (void)removeFoodAtIndex:(NSUInteger)index;
//- (void)moveFoodFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (Food*)insertFood;
- (void)removeFood:(Food*)food;
+ (NSArray*)placesFromPlaceSettingInfo:(FESearchPlaceSettingInfo*)placeSettingInfo;
+ (NSArray *)placesFromMapPlaceSettingInfo:(FEMapSearchPlaceSettingInfo *)placeSettingInfo;
+ (NSArray*)placesNearestLocation:(CLLocation*)location;
+ (NSArray *)placesWithEmptyAddress;
@end
