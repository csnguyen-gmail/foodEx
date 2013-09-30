//
//  User+Extension.h
//  feedEx
//
//  Created by csnguyen on 9/20/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "User.h"

@interface User (Extension)
+ (User*)getUser;
// argument nil mean no filter
+ (NSArray*)fetchUsersByEmail:(NSString*)email andUserType:(NSString*)type;
@end
