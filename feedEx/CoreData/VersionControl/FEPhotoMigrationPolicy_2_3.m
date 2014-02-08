//
//  FEPhotoMigrationPolicy.m
//  feedEx
//
//  Created by csnguyen on 9/16/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPhotoMigrationPolicy_2_3.h"
#import "Photo.h"
#import "ThumbnailPhoto.h"

@implementation FEPhotoMigrationPolicy_2_3
- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error {
    Photo *newPhoto = (Photo*)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:manager.destinationContext];
    ThumbnailPhoto* tbPhoto = (ThumbnailPhoto*)[NSEntityDescription insertNewObjectForEntityForName:@"ThumbnailPhoto" inManagedObjectContext:manager.destinationContext];
    tbPhoto.image = [sInstance valueForKey:@"thumbnailPhoto"];
    newPhoto.thumbnailPhoto = tbPhoto;
    
    [manager associateSourceInstance:sInstance withDestinationInstance:newPhoto forEntityMapping:mapping];
    return YES;
}

@end
