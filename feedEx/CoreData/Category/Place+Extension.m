//
//  Place+Extension.m
//  feedEx
//
//  Created by csnguyen on 7/18/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place+Extension.h"
#import "Common.h"

@implementation Place (Extension)
- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.lastTimeCheckin = self.createdDate;
}

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
+ (NSArray *)placesFromPlaceSettingInfo:(FESearchPlaceSettingInfo *)placeSettingInfo withMOC:(NSManagedObjectContext *)moc {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:moc];
    
    // filtering
    if (placeSettingInfo.name.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", placeSettingInfo.name];
        [predicates addObject:predicate];
    }
    if (placeSettingInfo.address.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address.address CONTAINS[cd] %@", placeSettingInfo.address];
        [predicates addObject:predicate];
    }
    if (placeSettingInfo.rating != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rating == %@", @(placeSettingInfo.rating)];
        [predicates addObject:predicate];
    }
    if (placeSettingInfo.tags.length > 0) {
        NSArray *tagsString = [placeSettingInfo.tags componentsSeparatedByString:SEPARATED_TAG_STR];
        NSMutableArray *tagPredicates = [[NSMutableArray alloc] init];
        for (NSString *tag in tagsString) {
            NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"tags.label CONTAINS[cd] %@", tag];
            [tagPredicates addObject:tagPredicate];
        }
        [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:tagPredicates]];
    }
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    // TODO: speed up by query by Tag
    // https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetchExpressions.html
    
    // sorting
    NSMutableArray *sorts = [[NSMutableArray alloc] init];
    if (placeSettingInfo.firstSort.length > 0) {
        NSArray *sortsString = [placeSettingInfo.firstSort componentsSeparatedByString:SEPARATED_SORT_STR];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:PLACE_SORT_TYPE_STRING_DICT[sortsString[0]]
                                                             ascending:[DIRECTION_STRING_LIST[0] isEqual:sortsString[1]]];
        [sorts addObject:sort];
    }
    if (placeSettingInfo.secondSort.length > 0) {
        NSArray *sortsString = [placeSettingInfo.secondSort componentsSeparatedByString:SEPARATED_SORT_STR];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:PLACE_SORT_TYPE_STRING_DICT[sortsString[0]]
                                                             ascending:[DIRECTION_STRING_LIST[0] isEqual:sortsString[1]]];
        [sorts addObject:sort];
    }
    request.sortDescriptors = sorts;
    
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;
}
+ (NSArray*)latestCheckinPlace:(NSUInteger)numberOfPlace withMOC:(NSManagedObjectContext *)moc {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:moc];
    
    // sorting
    NSArray *sorts = @[
//                       [[NSSortDescriptor alloc] initWithKey:@"lastTimeCheckin" ascending:NO],
                       [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO],
                       [[NSSortDescriptor alloc] initWithKey:@"timesCheckin" ascending:NO]
                       ];
    
    request.sortDescriptors = sorts;
    // batching size
    request.fetchBatchSize = numberOfPlace;
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;

}
@end
