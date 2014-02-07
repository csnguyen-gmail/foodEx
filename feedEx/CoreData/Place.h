//
//  Place.h
//  feedEx
//
//  Created by csnguyen on 2/7/14.
//  Copyright (c) 2014 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInfo.h"

@class Address, Food, User;

@interface Place : AbstractInfo

@property (nonatomic, retain) NSString * distanceInfo;
@property (nonatomic, retain) NSDate * lastTimeCheckin;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * timesCheckin;
@property (nonatomic, retain) Address *address;
@property (nonatomic, retain) NSSet *foods;
@property (nonatomic, retain) User *owner;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addFoodsObject:(Food *)value;
- (void)removeFoodsObject:(Food *)value;
- (void)addFoods:(NSSet *)values;
- (void)removeFoods:(NSSet *)values;

@end
