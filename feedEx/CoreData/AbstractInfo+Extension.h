//
//  AbstractInfo+Extension.h
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractInfo.h"
@interface AbstractInfo (Extension)
- (void)insertPhotoWithThumbnail:(UIImage*)thumbnailImage andOriginImage:(UIImage*)originImage atIndex:(NSUInteger)index;
- (Photo*)removePhotoAtIndex:(NSUInteger)index;
@end
