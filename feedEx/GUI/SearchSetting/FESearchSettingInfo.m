//
//  FESearchSettingInfo.m
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchSettingInfo.h"

@implementation FESearchPlaceSettingInfo
#define PLACE_SETTING_NAME @"PlaceSettingName"
#define PLACE_SETTING_ADDR @"PlaceSettingAddr"
#define PLACE_SETTING_RATE @"PlaceSettingRate"
#define PLACE_SETTING_TAGS @"PlaceSettingTags"
#define PLACE_SETTING_FIRST_SORT_STR @"PlaceSettingFirstSortStr"
#define PLACE_SETTING_FIRST_SORT_ASC @"PlaceSettingFirstSortAsc"
#define PLACE_SETTING_SECOND_SORT_STR @"PlaceSettingSecondSortStr"
#define PLACE_SETTING_SECOND_SORT_ASC @"PlaceSettingSecondSortAsc"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.name = [decoder decodeObjectForKey:PLACE_SETTING_NAME];
        self.address = [decoder decodeObjectForKey:PLACE_SETTING_ADDR];
        self.rating = [decoder decodeIntegerForKey:PLACE_SETTING_RATE];
        self.tags = [decoder decodeObjectForKey:PLACE_SETTING_TAGS];
        self.firstSortString = [decoder decodeObjectForKey:PLACE_SETTING_FIRST_SORT_STR];
        self.firstSortIsAscending = [decoder decodeBoolForKey:PLACE_SETTING_FIRST_SORT_ASC];
        self.secondSortString = [decoder decodeObjectForKey:PLACE_SETTING_SECOND_SORT_STR];
        self.secondSortIsAscending = [decoder decodeBoolForKey:PLACE_SETTING_SECOND_SORT_ASC];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:PLACE_SETTING_NAME];
    [encoder encodeObject:self.address forKey:PLACE_SETTING_ADDR];
    [encoder encodeInteger:self.rating forKey:PLACE_SETTING_RATE];
    [encoder encodeObject:self.tags forKey:PLACE_SETTING_TAGS];
    [encoder encodeObject:self.firstSortString forKey:PLACE_SETTING_FIRST_SORT_STR];
    [encoder encodeBool:self.firstSortIsAscending forKey:PLACE_SETTING_FIRST_SORT_ASC];
    [encoder encodeObject:self.secondSortString forKey:PLACE_SETTING_SECOND_SORT_STR];
    [encoder encodeBool:self.secondSortIsAscending forKey:PLACE_SETTING_SECOND_SORT_ASC];
}

@end

@implementation FESearchFoodSettingInfo
#define FOOD_SETTING_NAME @"FoodSettingName"
#define FOOD_SETTING_TAGS @"FoodSettingTags"
#define FOOD_SETTING_COST_EXPR @"FoodSettingCostExpr"
#define FOOD_SETTING_BEST_TYPE @"FoodSettingBestType"
#define FOOD_SETTING_FIRST_SORT_STR @"FoodSettingFirstSortStr"
#define FOOD_SETTING_FIRST_SORT_ASC @"FoodSettingFirstSortAsc"
#define FOOD_SETTING_SECOND_SORT_STR @"FoodSettingSecondSortStr"
#define FOOD_SETTING_SECOND_SORT_ASC @"FoodSettingSecondSortAsc"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.name = [decoder decodeObjectForKey:FOOD_SETTING_NAME];
        self.tags = [decoder decodeObjectForKey:FOOD_SETTING_TAGS];
        self.costExpression = [decoder decodeObjectForKey:FOOD_SETTING_COST_EXPR];
        self.bestType = [decoder decodeIntegerForKey:FOOD_SETTING_BEST_TYPE];
        self.firstSortString = [decoder decodeObjectForKey:FOOD_SETTING_FIRST_SORT_STR];
        self.firstSortIsAscending = [decoder decodeBoolForKey:FOOD_SETTING_FIRST_SORT_ASC];
        self.secondSortString = [decoder decodeObjectForKey:FOOD_SETTING_SECOND_SORT_STR];
        self.secondSortIsAscending = [decoder decodeBoolForKey:FOOD_SETTING_SECOND_SORT_ASC];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:FOOD_SETTING_NAME];
    [encoder encodeObject:self.tags forKey:FOOD_SETTING_TAGS];
    [encoder encodeObject:self.costExpression forKey:FOOD_SETTING_COST_EXPR];
    [encoder encodeInteger:self.bestType forKey:FOOD_SETTING_BEST_TYPE];
    [encoder encodeObject:self.firstSortString forKey:FOOD_SETTING_FIRST_SORT_STR];
    [encoder encodeBool:self.firstSortIsAscending forKey:FOOD_SETTING_FIRST_SORT_ASC];
    [encoder encodeObject:self.secondSortString forKey:FOOD_SETTING_SECOND_SORT_STR];
    [encoder encodeBool:self.secondSortIsAscending forKey:FOOD_SETTING_SECOND_SORT_ASC];
}

@end

@implementation FESearchSettingInfo
#define PLACE_SETTING_KEY @"PlaceSetting"
#define FOOD_SETTING_KEY @"FoodSetting"
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.placeSetting = [decoder decodeObjectForKey:PLACE_SETTING_KEY];
        self.foodSetting = [decoder decodeObjectForKey:FOOD_SETTING_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.placeSetting forKey:PLACE_SETTING_KEY];
    [encoder encodeObject:self.foodSetting forKey:FOOD_SETTING_KEY];
}

@end
