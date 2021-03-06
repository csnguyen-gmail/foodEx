//
//  Tag+Extension.m
//  feedEx
//
//  Created by csnguyen on 6/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Tag+Extension.h"
#import "CoredataCommon.h"
#import "FECoreDataController.h"
@implementation Tag (Extension)
+ (NSArray*)fetchTagsByType:(NSNumber*)type{
    FECoreDataController *coredata = [FECoreDataController sharedInstance];
    NSFetchRequest *fetchRequest = [coredata.managedObjectModel fetchRequestFromTemplateWithName:FR_GetTagByType
                                                                           substitutionVariables:@{FR_GetTagByType_Type:type}];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES]]];
    return [coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}
+ (NSArray*)fetchTagsByType:(NSNumber*)type andLabel:(NSString*)label {
    FECoreDataController *coredata = [FECoreDataController sharedInstance];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:coredata.managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat:@"type == %@ AND label == %@", type, label];
    NSError *error = nil;
    NSArray *results = [coredata.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;
}
@end
