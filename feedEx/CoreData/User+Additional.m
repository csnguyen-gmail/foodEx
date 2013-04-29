//
//  User+Additional.m
//  feedEx
//
//  Created by csnguyen on 4/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "User+Additional.h"

@implementation User (Additional)
+ (User *)getUserInManagedObjectContext:(NSManagedObjectContext *)context {
    User *user;
    NSError *error;
    
    // fetch User list
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *users = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    // not created yet
    if (users.count == 0) {
        // load default User
        NSString *path = [[NSBundle mainBundle] pathForResource:@"default_info" ofType:@"plist"];
        NSDictionary *defaultInfo = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSDictionary *userInfo = defaultInfo[@"User"];
        // and insert to core data
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.createdDate = [NSDate date];
        user.name = userInfo[@"name"];
        user.note = userInfo[@"note"];
        // save core data
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    // created then return
    else if (users.count == 1) {
        user = users.lastObject;
    }
    // error
    else {
        NSLog(@"Duplicate User");
    }    
    return user;
}
@end
