//
//  Address.h
//  feedEx
//
//  Created by csnguyen on 6/9/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * attittude;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) Place *placeOwner;

@end
