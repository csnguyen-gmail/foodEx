//
//  Address.h
//  feedEx
//
//  Created by csnguyen on 5/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * attittude;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) NSString * ward;
@property (nonatomic, retain) Place *placeOwner;

@end
