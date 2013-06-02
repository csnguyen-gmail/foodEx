//
//  AbstractInfo+Extension.m
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractInfo+Extension.h"
#import "UIImage+Extension.h"
#import "Photo.h"

@implementation AbstractInfo (Extension)
- (void)awakeFromInsert {
    self.createdDate = [NSDate date];
}
- (void)insertThumbnailAndOriginImage:(UIImage*)image atIndex:(NSUInteger)index {
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.imageData = UIImagePNGRepresentation(image);
        photo.thumbnailPhoto = [UIImage imageWithImage:image scaledToSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];

//        [self insertObject:photo inPhotosAtIndex:index]; --> this function seem not work at the moment, what a shame!
        NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.photos];
        [tempSet insertObject:photo atIndex:index];
        self.photos = tempSet;
    }
}
@end
