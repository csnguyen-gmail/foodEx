//
//  FEDataSerialize.h
//  feedEx
//
//  Created by csnguyen on 8/26/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

#define USER_KEY @"user"
#define PLACES_KEY @"places"

@interface FEDataSerialize : NSObject
+ (NSData*)serializeMailData:(NSDictionary*)placeInfo;
+ (NSDictionary*)deserializeMailData:(NSData*)data;
@end
