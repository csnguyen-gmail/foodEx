//
//  Tag.h
//  feedEx
//
//  Created by csnguyen on 2/7/14.
//  Copyright (c) 2014 csnguyen. All rights reserved.
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
