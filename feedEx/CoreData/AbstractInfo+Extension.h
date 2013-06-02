//
//  AbstractInfo+Extension.h
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractInfo.h"
#define THUMBNAIL_WIDTH 64
#define THUMBNAIL_HEIGHT 64

@interface AbstractInfo (Extension)
- (void)insertThumbnailAndOriginImage:(UIImage*)image atIndex:(NSUInteger)index;
@end
