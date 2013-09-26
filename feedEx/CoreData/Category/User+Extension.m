//
//  User+Extension.m
//  feedEx
//
//  Created by csnguyen on 9/20/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "User+Extension.h"
#import "CoredataCommon.h"
#import "Tag.h"
#import "Place.h"
#import "FECoreDataController.h"

@implementation User (Extension)
+ (User *)getUser {
    static User *shared = nil;
    if (shared == nil) {
        FECoreDataController *coredata = [FECoreDataController sharedInstance];
        // lookup User
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:coredata.managedObjectContext];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY tags.type == %@", USER_OWNER_TAG];
        NSError *error = nil;
        NSArray *results = [coredata.managedObjectContext executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return nil;
        }
        // Get User in case User created
        if (results.count != 0) {
            shared = results[0];
        }
        // Create User in case User not created yet
        else {
            shared = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:coredata.managedObjectContext];
            // Tag
            Tag* tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:coredata.managedObjectContext];
            tag.type = CD_TAG_USER;
            tag.label = USER_OWNER_TAG;
            [tag addOwnerObject:shared];
            // Places: set owner for un-owner Place
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:coredata.managedObjectContext];
            request.predicate = [NSPredicate predicateWithFormat:@"owner == nil"];
            NSError *error = nil;
            NSArray *results = [coredata.managedObjectContext executeFetchRequest:request error:&error];
            if (error) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                return nil;
            }
            for (Place *place in results) {
                place.owner = shared;
            }
            [coredata saveToPersistenceStoreAndWait];
        }
    }
    
    return shared;
}
@end
