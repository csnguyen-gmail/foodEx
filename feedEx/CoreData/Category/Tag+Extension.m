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
@end
