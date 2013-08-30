//
//  Place.h
//  feedEx
//
//  Created by csnguyen on 8/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInfo.h"

@class Address, Food, User;

@interface Place : AbstractInfo

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * timesCheckin;
@property (nonatomic, retain) Address *address;
@property (nonatomic, retain) NSOrderedSet *foods;
@property (nonatomic, retain) User *owner;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)insertObject:(Food *)value inFoodsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFoodsAtIndex:(NSUInteger)idx;
- (void)insertFoods:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFoodsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFoodsAtIndex:(NSUInteger)idx withObject:(Food *)value;
- (void)replaceFoodsAtIndexes:(NSIndexSet *)indexes withFoods:(NSArray *)values;
- (void)addFoodsObject:(Food *)value;
- (void)removeFoodsObject:(Food *)value;
- (void)addFoods:(NSOrderedSet *)values;
- (void)removeFoods:(NSOrderedSet *)values;
@end
