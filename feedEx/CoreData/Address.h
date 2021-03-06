//
//  Address.h
//  feedEx
//
//  Created by csnguyen on 2/7/14.
//  Copyright (c) 2014 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * lattittude;
@property (nonatomic, retain) NSNumber * longtitude;
@property (nonatomic, retain) Place *owner;

@end
