//
//  AbstractInfo+Extension.h
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractInfo.h"
#define THUMBNAIL_WIDTH 50
#define THUMBNAIL_HEIGHT 50

@interface AbstractInfo (Extension)
- (void)setThumbnailAndOriginImage:(UIImage*)image;
@end
