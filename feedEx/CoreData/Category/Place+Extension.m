//
//  Place+Extension.m
//  feedEx
//
//  Created by csnguyen on 7/18/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place+Extension.h"
#import "Common.h"
#import "Address.h"

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
#define ACCEPTABLE_CHECKIN_RADIUS 30.0 // meters
// TODO: should consider a better way to filter Place by distance
+ (NSArray*)placesNearestLocation:(CLLocation*)location withMOC:(NSManagedObjectContext *)moc {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:moc];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    NSMutableArray *nearestPlaces = [NSMutableArray array];
    for (Place *place in results) {
        CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[place.address.lattittude doubleValue]
                                                               longitude:[place.address.longtitude doubleValue]];
        CLLocationDistance distance = [location distanceFromLocation:placeLocation];
        if (distance <= ACCEPTABLE_CHECKIN_RADIUS) {
            [nearestPlaces addObject:place];
        }
    }
    
    return nearestPlaces;
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY tags.label in %@", tagsString];
        [predicates addObject:predicate];
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
+ (NSArray *)placesWithEmptyAddress:(NSManagedObjectContext *)moc {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:moc];
    
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    [predicates addObject:[NSPredicate predicateWithFormat:@"address.address == nil OR address.address == ''"]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"address.longtitude != 0 AND address.lattittude != 0"]];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;
}

@end
