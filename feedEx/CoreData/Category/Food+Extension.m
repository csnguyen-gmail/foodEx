//
//  Food+Extension.m
//  feedEx
//
//  Created by csnguyen on 9/6/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Food+Extension.h"
#import "Common.h"
#import "FECoreDataController.h"

@implementation Food (Extension)
+ (NSArray *)foodsFromFoodSettingInfo:(FESearchFoodSettingInfo *)foodSettingInfo {
    FECoreDataController *coredata = [FECoreDataController sharedInstance];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Food" inManagedObjectContext:coredata.managedObjectContext];
    
    // filtering
    if (foodSettingInfo.name.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", foodSettingInfo.name];
        [predicates addObject:predicate];
    }
    if (foodSettingInfo.tags.length > 0) {
        NSArray *tagsString = [foodSettingInfo.tags componentsSeparatedByString:SEPARATED_TAG_STR];
        NSMutableArray *tagPredicates = [[NSMutableArray alloc] init];
        for (NSString *tag in tagsString) {
            NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"tags.label CONTAINS[cd] %@", tag];
            [tagPredicates addObject:tagPredicate];
        }
        [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:tagPredicates]];
    }
    // TODO Cost
    
    if (foodSettingInfo.bestType != 0) { // is not All
        NSString *predicateStr = [NSString stringWithFormat:@"isBest %@ 1", (foodSettingInfo.bestType == 1 ? @"==" : @"!=")];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateStr];
        [predicates addObject:predicate];
    }
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    // TODO: speed up by query by Tag
    // https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetchExpressions.html
    
    // sorting
    NSMutableArray *sorts = [[NSMutableArray alloc] init];
    if (foodSettingInfo.firstSort.length > 0) {
        NSArray *sortsString = [foodSettingInfo.firstSort componentsSeparatedByString:SEPARATED_SORT_STR];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:FOOD_SORT_TYPE_STRING_DICT[sortsString[0]]
                                                             ascending:[DIRECTION_STRING_LIST[0] isEqual:sortsString[1]]];
        [sorts addObject:sort];
    }
    if (foodSettingInfo.secondSort.length > 0) {
        NSArray *sortsString = [foodSettingInfo.secondSort componentsSeparatedByString:SEPARATED_SORT_STR];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:FOOD_SORT_TYPE_STRING_DICT[sortsString[0]]
                                                             ascending:[DIRECTION_STRING_LIST[0] isEqual:sortsString[1]]];
        [sorts addObject:sort];
    }
    request.sortDescriptors = sorts;
    
    
    NSError *error = nil;
    NSArray *results = [coredata.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;
}
@end
