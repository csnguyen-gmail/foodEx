//
//  FEDebug.m
//  feedEx
//
//  Created by csnguyen on 9/28/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEDebug.h"
#import "FECoreDataController.h"
#import "Place.h"
#import "User.h"
#import "Tag.h"
#import "Photo.h"
#import "ThumbnailPhoto.h"
#import "OriginPhoto.h"

@implementation FEDebug
+ (void)printOutDbContent {
    FECoreDataController *coredata = [FECoreDataController sharedInstance];
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:coredata.managedObjectContext];
    NSArray *_users = [coredata.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"USER");
    for (User *user in _users) {
        Tag *tag = [user.tags anyObject];
        NSLog(@"  email:%@ name:%@ - %@", user.email, user.name, tag.label);
    }
    request.entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:coredata.managedObjectContext];
    NSArray *_tags = [coredata.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"TAG");
    for (Tag *tag in _tags) {
        NSLog(@"  %@ - num %d", tag.label, tag.owner.count);
    }
    
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:coredata.managedObjectContext];
    NSArray *_places = [coredata.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"PLACE");
    for (Place *place in _places) {
        NSLog(@"  %@ - email:%@ name:%@  - %@", place.name, place.owner.email, place.owner.name, [[place.owner.tags anyObject] label]);
    }
}
+ (void)printOutImageSize {
    FECoreDataController *coredata = [FECoreDataController sharedInstance];
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:coredata.managedObjectContext];
    NSArray *photos = [coredata.managedObjectContext executeFetchRequest:request error:&error];
    NSUInteger total = 0;
    NSUInteger count = 0;
    for (Photo *photo in photos) {
        ThumbnailPhoto *thumb = photo.thumbnailPhoto;
        OriginPhoto *origin = photo.originPhoto;
        UIImage *thumbImage = (UIImage*)thumb.image;
        UIImage *originImage = [UIImage imageWithData:origin.imageData scale:[[UIScreen mainScreen] scale]];
        NSUInteger thumbSize = [UIImagePNGRepresentation(thumbImage) length];
        NSUInteger originSize = [origin.imageData length];
        NSLog(@"thumb: %@ %f %i, origin: %@, %f %i", NSStringFromCGSize(thumbImage.size), thumbImage.scale, thumbSize, NSStringFromCGSize(originImage.size), originImage.scale, originSize);
        total += thumbSize;
        total += originSize;
        count += 2;
    }
    NSLog(@"Count: %d Total: %.2f", count, (float)total/1024.0f/1024.0f);
}

@end
