//
//  Place+Extension.m
//  feedEx
//
//  Created by csnguyen on 7/18/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place+Extension.h"

@implementation Place (Extension)
- (void)insertFoodsAtIndex:(NSUInteger)index {
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        Food *food = [NSEntityDescription insertNewObjectForEntityForName:@"Food" inManagedObjectContext:context];
        NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.foods];
        [tempSet insertObject:food atIndex:index];
        self.foods = tempSet;
    }
}
- (void)removeFoodAtIndex:(NSUInteger)index {
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.foods];
        Food *food = [self.foods objectAtIndex:index];
        [tempSet removeObjectAtIndex:index];
        self.foods = tempSet;
        [context deleteObject:food];
    }
}
- (void)moveFoodFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.foods];
    [tempSet moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] toIndex:toIndex];
    self.foods = tempSet;
}
@end
