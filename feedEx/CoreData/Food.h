//
//  Food.h
//  feedEx
//
//  Created by csnguyen on 2/7/14.
//  Copyright (c) 2014 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInfo.h"

@class Place;

@interface Food : AbstractInfo

@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSNumber * isBest;
@property (nonatomic, retain) Place *owner;

@end
