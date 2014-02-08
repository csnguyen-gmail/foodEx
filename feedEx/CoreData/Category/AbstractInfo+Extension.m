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

- (void)insertPhotoWithThumbnail:(UIImage *)thumbnailImage andOriginImage:(UIImage *)originImage {
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
        photo.order = @(self.photos.count);
        photo.owner = self;
    }
}

- (void)removePhotoAtIndex:(NSUInteger)index {
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        NSMutableArray *photos = [NSMutableArray arrayWithArray:[self arrayPhotos]];
        // remove Photo
        Photo *removedPhoto = photos[index];
        [photos removeObject:removedPhoto];
        [context deleteObject:removedPhoto];
        // update Photo order
        for (int i = 0; i < photos.count; i++) {
            Photo *photo = photos[i];
            photo.order = @(i);
        }
    }
}

- (void)movePhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    NSMutableArray *photos = [NSMutableArray arrayWithArray:[self arrayPhotos]];
    id object = [photos objectAtIndex:fromIndex];
    [photos removeObjectAtIndex:fromIndex];
    [photos insertObject:object atIndex:toIndex];
    // update Photo order
    for (int i = 0; i < photos.count; i++) {
        Photo *photo = photos[i];
        photo.order = @(i);
    }
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

- (Photo *)firstPhoto {
    return [self arrayPhotos][0];
}

- (NSArray*)arrayPhotos {
    if (self.photos.count == 0) {
        return nil;
    }
    Photo* photo = [self.photos anyObject];
    photo.order;
    return [self.photos sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]]];
}
@end
