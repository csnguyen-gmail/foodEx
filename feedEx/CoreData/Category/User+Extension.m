//
//  User+Extension.m
//  feedEx
//
//  Created by csnguyen on 9/20/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "User+Extension.h"

@implementation User (Extension)
+ (User *)getUser:(NSManagedObjectContext *)moc {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    
    return results.count == 0 ? nil : results[0];
}
@end
