//
//  AbstractInfo+Extension.m
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractInfo+Extension.h"
#import "Photo.h"

@implementation AbstractInfo (Extension)
- (void)awakeFromInsert {
    self.createdDate = [NSDate date];
}
- (void)insertPhotoWithThumbnail:(UIImage *)thumbnailImage andOriginImage:(UIImage *)originImage atIndex:(NSUInteger)index {
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.imageData = UIImagePNGRepresentation(originImage);
        if (thumbnailImage) {
            photo.thumbnailPhoto = thumbnailImage;
        }
        else {
            photo.thumbnailPhoto = [UIImage imageWithImage:originImage scaledToSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
        }
//        [self insertObject:photo inPhotosAtIndex:index]; // --> this function seem not work at the moment, what a shame!
        NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.photos];
        [tempSet insertObject:photo atIndex:index];
        self.photos = tempSet;
    }
}
- (Photo*)removePhotoAtIndex:(NSUInteger)index {
//    [self removeObjectFromPhotosAtIndex:index]; // --> this function seem not work at the moment, what a shame!
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.photos];
    Photo *photo = [self.photos objectAtIndex:index];
    [tempSet removeObjectAtIndex:index];
    self.photos = tempSet;
    return  photo;
}
- (void)movePhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.photos];
    [tempSet moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:fromIndex] toIndex:toIndex];
    self.photos = tempSet;
}
- (void)updateTagWithStringTags:(NSArray*)stringTags andTagType:(NSNumber*)tagtype inTags:(NSArray*)tags byMOC:(NSManagedObjectContext*)moc {
    for (Tag *tag in self.tags) {
        [tag removeOwnerObject:self];
    }
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
            savingTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc];
            savingTag.label = stringTag;
            savingTag.type = tagtype;
        }
        // add tag
        [savingTag addOwnerObject:self];
    }
}
- (void)deleteAndUpateTagWithMOC:(NSManagedObjectContext *)moc {
    NSOrderedSet *tempTags = self.tags;
    [moc deleteObject:self];
    for (Tag *tag in tempTags) {
        if (tag.owner.count == 0) {
            [moc deleteObject:tag];
        }
    }
}
- (NSString *)buildTagsString {
    if (self.tags.count == 0) {
        return  nil;
    }
    NSMutableString *tagsString = [[NSMutableString alloc] init];
    int i;
    for (i = 0; i < self.tags.count - 1; i++) {
        [tagsString appendFormat:@"%@, ", [self.tags[i] label]];
    }
    [tagsString appendString:[self.tags[i] label]];
    return tagsString;
}
@end
