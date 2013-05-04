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
- (void)setThumbnailAndOriginImage:(UIImage*)image {
    self.thumbnailPhoto = [UIImage imageWithImage:image scaledToSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
    NSManagedObjectContext *context = self.managedObjectContext;
    if (context) {
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.imageData = UIImagePNGRepresentation(image);
        photo.owner = self;
    }
}
@end
