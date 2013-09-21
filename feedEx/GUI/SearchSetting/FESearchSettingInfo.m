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
#define PLACE_SETTING_FIRST_SORT @"PlaceSettingFirstSort"
#define PLACE_SETTING_SECOND_SORT @"PlaceSettingSecondSort"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.name = [decoder decodeObjectForKey:PLACE_SETTING_NAME];
        self.address = [decoder decodeObjectForKey:PLACE_SETTING_ADDR];
        self.rating = [decoder decodeIntegerForKey:PLACE_SETTING_RATE];
        self.tags = [decoder decodeObjectForKey:PLACE_SETTING_TAGS];
        self.firstSort = [decoder decodeObjectForKey:PLACE_SETTING_FIRST_SORT];
        self.secondSort = [decoder decodeObjectForKey:PLACE_SETTING_SECOND_SORT];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:PLACE_SETTING_NAME];
    [encoder encodeObject:self.address forKey:PLACE_SETTING_ADDR];
    [encoder encodeInteger:self.rating forKey:PLACE_SETTING_RATE];
    [encoder encodeObject:self.tags forKey:PLACE_SETTING_TAGS];
    [encoder encodeObject:self.firstSort forKey:PLACE_SETTING_FIRST_SORT];
    [encoder encodeObject:self.secondSort forKey:PLACE_SETTING_SECOND_SORT];
}

@end

@implementation FESearchFoodSettingInfo
#define FOOD_SETTING_NAME @"FoodSettingName"
#define FOOD_SETTING_TAGS @"FoodSettingTags"
#define FOOD_SETTING_COST_EXPR @"FoodSettingCostExpr"
#define FOOD_SETTING_BEST_TYPE @"FoodSettingBestType"
#define FOOD_SETTING_FIRST_SORT @"FoodSettingFirstSort"
#define FOOD_SETTING_SECOND_SORT @"FoodSettingSecondSort"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.name = [decoder decodeObjectForKey:FOOD_SETTING_NAME];
        self.tags = [decoder decodeObjectForKey:FOOD_SETTING_TAGS];
        self.costExpression = [decoder decodeObjectForKey:FOOD_SETTING_COST_EXPR];
        self.bestType = [decoder decodeIntegerForKey:FOOD_SETTING_BEST_TYPE];
        self.firstSort = [decoder decodeObjectForKey:FOOD_SETTING_FIRST_SORT];
        self.secondSort = [decoder decodeObjectForKey:FOOD_SETTING_SECOND_SORT];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:FOOD_SETTING_NAME];
    [encoder encodeObject:self.tags forKey:FOOD_SETTING_TAGS];
    [encoder encodeObject:self.costExpression forKey:FOOD_SETTING_COST_EXPR];
    [encoder encodeInteger:self.bestType forKey:FOOD_SETTING_BEST_TYPE];
    [encoder encodeObject:self.firstSort forKey:FOOD_SETTING_FIRST_SORT];
    [encoder encodeObject:self.secondSort forKey:FOOD_SETTING_SECOND_SORT];
}

@end

@implementation FESearchSettingInfo
#define DISP_TYPE_KEY @"DisplayTypeSetting"
#define PLACE_SETTING_KEY @"PlaceSetting"
#define FOOD_SETTING_KEY @"FoodSetting"
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.displayType = [decoder decodeIntegerForKey:DISP_TYPE_KEY];
        self.placeSetting = [decoder decodeObjectForKey:PLACE_SETTING_KEY];
        self.foodSetting = [decoder decodeObjectForKey:FOOD_SETTING_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.displayType forKey:DISP_TYPE_KEY];
    [encoder encodeObject:self.placeSetting forKey:PLACE_SETTING_KEY];
    [encoder encodeObject:self.foodSetting forKey:FOOD_SETTING_KEY];
}
@end
@implementation FEMapSearchPlaceSettingInfo
#define MAP_PLACE_SETTING_RATE @"MapPlaceSettingRate"
#define MAP_PLACE_SETTING_TAGS @"MapPlaceSettingTags"

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.rating = [decoder decodeIntegerForKey:PLACE_SETTING_RATE];
        self.tags = [decoder decodeObjectForKey:PLACE_SETTING_TAGS];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.rating forKey:PLACE_SETTING_RATE];
    [encoder encodeObject:self.tags forKey:PLACE_SETTING_TAGS];
}

@end

