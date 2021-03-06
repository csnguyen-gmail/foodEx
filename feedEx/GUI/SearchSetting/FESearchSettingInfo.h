//
//  FESearchSettingInfo.h
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface FESearchPlaceSettingInfo: NSObject<NSCoding>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) NSUInteger rating;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *firstSort;
@property (nonatomic, strong) NSString *secondSort;
@end

#define FOOD_BEST_ALL   0
#define FOOD_BEST_YES   1
#define FOOD_BEST_NONE  2
@interface FESearchFoodSettingInfo: NSObject<NSCoding>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *costExpression;
@property (nonatomic) NSUInteger bestType;
@property (nonatomic, strong) NSString *firstSort;
@property (nonatomic, strong) NSString *secondSort;
@end

#define SEARCH_SETTING_KEY @"SearchSettingKey"
@interface FESearchSettingInfo : NSObject<NSCoding>
@property (nonatomic, strong) FESearchPlaceSettingInfo *placeSetting;
@property (nonatomic, strong) FESearchFoodSettingInfo *foodSetting;
@end

#define MAP_SEARCH_SETTING_KEY @"MapSearchSettingKey"
#define SEARCH_BY_ALL       0
#define SEARCH_BY_NAME      1
#define SEARCH_BY_ADDRESS   2
@interface FEMapSearchPlaceSettingInfo : NSObject<NSCoding>
@property (nonatomic) NSUInteger rating;
@property (nonatomic) NSUInteger searchBy;
@property (nonatomic, strong) NSString *tags;
@end
