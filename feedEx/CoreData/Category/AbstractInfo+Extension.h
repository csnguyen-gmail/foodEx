//
//  AbstractInfo+Extension.h
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractInfo.h"
#import "Tag.h"
#import "Photo.h"
@interface AbstractInfo (Extension)
- (void)insertPhotoWithThumbnail:(UIImage*)thumbnailImage andOriginImage:(UIImage*)originImage;
- (void)removePhotoAtIndex:(NSUInteger)index;
- (void)movePhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)updateTagWithStringTags:(NSArray*)stringTags andTagType:(NSNumber*)tagtype inTags:(NSArray*)tags;
- (Photo*)firstPhoto;
- (NSArray*)arrayPhotos;
@end
