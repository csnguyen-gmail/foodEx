//
//  Tag+Extension.m
//  feedEx
//
//  Created by csnguyen on 6/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Tag+Extension.h"
#import "CoredataCommon.h"
@implementation Tag (Extension)
+ (NSArray*)fetchTagsByType:(NSNumber*)type withMOM:(NSManagedObjectModel*)mom andMOC:(NSManagedObjectContext*)moc {
    NSFetchRequest *fetchRequest = [mom fetchRequestFromTemplateWithName:FR_GetTagByType
                                                   substitutionVariables:@{FR_GetTagByType_Type:type}];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES]]];
    return [moc executeFetchRequest:fetchRequest error:nil];
}
@end
