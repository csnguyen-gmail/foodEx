//
//  AbstractInfo+Extension.m
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractInfo+Extension.h"
#import "Photo.h"
#import "OriginPhoto.h"
#import "Common.h"
#import "ThumbnailPhoto.h"

@implementation AbstractInfo (Extension)
- (void)awakeFromInsert {
    self.createdDate = [NSDate date];
}
- (void)insertPhotoWithThumbnail:(UIImage *)thumbnailImage andOriginImage:(UIImage *)originImage atIndex:(NSUInteger)index {
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];

        OriginPhoto *originPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"OriginPhoto" inManagedObjectContext:context];
        originPhoto.imageData = UIImagePNGRepresentation(originImage);
        photo.originPhoto = originPhoto;
        
        ThumbnailPhoto *thumbnailPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"ThumbnailPhoto" inManagedObjectContext:context];
        if (thumbnailImage) {
            thumbnailPhoto.image = thumbnailImage;
        }
        else {
            thumbnailPhoto.image = [UIImage imageWithImage:originImage scaledToSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
        }
        photo.thumbnailPhoto = thumbnailPhoto;
        
//        [self insertObject:photo inPhotosAtIndex:index]; // --> this function seem not work at the moment, what a shame!
        NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.photos];
        [tempSet insertObject:photo atIndex:index];
        self.photos = tempSet;
    }
}
- (void)removePhotoAtIndex:(NSUInteger)index {
//    [self removeObjectFromPhotosAtIndex:index]; // --> this function seem not work at the moment, what a shame!
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.photos];
        Photo *photo = [self.photos objectAtIndex:index];
        [tempSet removeObjectAtIndex:index];
        self.photos = tempSet;
        [context deleteObject:photo];
    }
}
- (void)movePhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.photos];
    [tempSet moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] toIndex:toIndex];
    self.photos = tempSet;
}
- (void)updateTagWithStringTags:(NSArray*)stringTags andTagType:(NSNumber*)tagtype inTags:(NSArray*)tags {
    [self.tags enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [(Tag*)obj removeOwnerObject:self];
    }];
    // add new tags
    for (NSString *stringTag in stringTags) {
        // get saving tag
        Tag *savingTag;
        for (Tag *tag in tags) {
            if ([tag.label isEqualToString:stringTag]) {
                savingTag = tag;
                break;
            }
        }
        // create new one in case there is not existed
        if (!savingTag) {
            savingTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:self.managedObjectContext];
            savingTag.label = stringTag;
            savingTag.type = tagtype;
        }
        // add tag
        [savingTag addOwnerObject:self];
    }
}
//- (NSString *)buildTagsString {
//    if (self.tags.count == 0) {
//        return  nil;
//    }
//    NSMutableString *tagsString = [[NSMutableString alloc] init];
//    int i;
//    for (i = 0; i < self.tags.count - 1; i++) {
//        [tagsString appendFormat:@"%@, ", [self.tags[i] label]];
//    }
//    [tagsString appendString:[self.tags[i] label]];
//    return tagsString;
//}
@end
