//
//  Food.h
//  feedEx
//
//  Created by csnguyen on 5/5/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInfo.h"

@class Place;

@interface Food : AbstractInfo

@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSNumber * isBest;
@property (nonatomic, retain) Place *placeOwner;

@end
