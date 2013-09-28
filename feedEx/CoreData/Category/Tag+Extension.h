//
//  Tag+Extension.h
//  feedEx
//
//  Created by csnguyen on 6/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Tag.h"

@interface Tag (Extension)
+ (NSArray*)fetchTagsByType:(NSNumber*)type;
@end
