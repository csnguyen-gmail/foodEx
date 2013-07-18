//
//  Place+Extension.h
//  feedEx
//
//  Created by csnguyen on 7/18/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place.h"
#import "Food.h"

@interface Place (Extension)
- (void)insertFoodsAtIndex:(NSUInteger)index;
- (void)removeFoodAtIndex:(NSUInteger)index;
- (void)moveFoodFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
@end