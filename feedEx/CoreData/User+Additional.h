//
//  User+Additional.h
//  feedEx
//
//  Created by csnguyen on 4/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "User.h"

@interface User (Additional)
+ (User*)getUserInManagedObjectContext:(NSManagedObjectContext*)context;
@end
