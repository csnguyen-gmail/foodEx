//
//  AbstractInfo.h
//  feedEx
//
//  Created by csnguyen on 6/2/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Tag;

@interface AbstractInfo : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSOrderedSet *photos;
@property (nonatomic, retain) NSSet *tags;
@end

@interface AbstractInfo (CoreDataGeneratedAccessors)

- (void)insertObject:(Photo *)value inPhotosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotosAtIndex:(NSUInteger)idx;
- (void)insertPhotos:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotosAtIndex:(NSUInteger)idx withObject:(Photo *)value;
- (void)replacePhotosAtIndexes:(NSIndexSet *)indexes withPhotos:(NSArray *)values;
- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSOrderedSet *)values;
- (void)removePhotos:(NSOrderedSet *)values;
- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
