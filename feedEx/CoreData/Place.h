//
//  Place.h
//  feedEx
//
//  Created by csnguyen on 5/3/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInfo.h"

@class Food, User;

@interface Place : AbstractInfo

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * attitude;
@property (nonatomic, retain) NSNumber * averageCost;
@property (nonatomic, retain) NSNumber * costlyLevel;
@property (nonatomic, retain) NSNumber * elegantLevel;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSString * mealType;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * tastyLavel;
@property (nonatomic, retain) NSNumber * timesCheckin;
@property (nonatomic, retain) NSSet *foods;
@property (nonatomic, retain) User *whose;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addFoodsObject:(Food *)value;
- (void)removeFoodsObject:(Food *)value;
- (void)addFoods:(NSSet *)values;
- (void)removeFoods:(NSSet *)values;

@end
