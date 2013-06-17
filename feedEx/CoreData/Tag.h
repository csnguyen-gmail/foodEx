//
//  Tag.h
//  feedEx
//
//  Created by csnguyen on 6/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractInfo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet *owner;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addOwnerObject:(AbstractInfo *)value;
- (void)removeOwnerObject:(AbstractInfo *)value;
- (void)addOwner:(NSSet *)values;
- (void)removeOwner:(NSSet *)values;

@end
