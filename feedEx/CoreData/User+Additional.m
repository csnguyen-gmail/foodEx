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
    // created then return
    if (users.count == 1) {
        user = users.lastObject;
    }
    // error
    else {
        NSLog(@"Load User failed");
    }    
    return user;
}
@end
