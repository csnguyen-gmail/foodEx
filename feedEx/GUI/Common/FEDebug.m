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

@implementation FEDebug
+ (void)printOutDbContent {
    FECoreDataController *coredata = [FECoreDataController sharedInstance];
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:coredata.managedObjectContext];
    NSArray *_users = [coredata.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"USER");
    for (User *user in _users) {
        Tag *tag = user.tags[0];
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
        NSLog(@"  %@ - email:%@ name:%@  - %@", place.name, place.owner.email, place.owner.name, [place.owner.tags[0] label]);
    }
}

@end
