//
//  User.h
//  feedEx
//
//  Created by csnguyen on 5/3/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractInfo.h"

@class Place;

@interface User : AbstractInfo

@property (nonatomic, retain) NSSet *places;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Place *)value;
- (void)removePlacesObject:(Place *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
