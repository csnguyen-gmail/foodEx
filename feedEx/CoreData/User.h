//
//  User.h
//  feedEx
//
//  Created by csnguyen on 2/7/14.
//  Copyright (c) 2014 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInfo.h"

@class Place;

@interface User : AbstractInfo

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *places;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Place *)value;
- (void)removePlacesObject:(Place *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
