//
//  FEAbstractInfoMigrationPolicy_5_6.m
//  feedEx
//
//  Created by csnguyen on 2/8/14.
//  Copyright (c) 2014 csnguyen. All rights reserved.
//

#import "FEAbstractInfoMigrationPolicy_5_6.h"
#import "AbstractInfo.h"
#import "Photo.h"

@implementation FEAbstractInfoMigrationPolicy_5_6

-(BOOL)createRelationshipsForDestinationInstance:(NSManagedObject *)dInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error {
    NSLog(@"Migrate: %@, create relationship for destination object", mapping.name);
    
    // call super to make sure LightWeight modification
    [super createRelationshipsForDestinationInstance:dInstance entityMapping:mapping manager:manager error:error];
    
    AbstractInfo *abstractInfo = (AbstractInfo*)dInstance;
    
    __block int count = 0;
    [abstractInfo.photos enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        Photo *photo = obj;
        photo.order = @(count);
        count++;
    }];
    return YES;
}

@end
