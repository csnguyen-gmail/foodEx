//
//  NSData+Extension.h
//  feedEx
//
//  Created by csnguyen on 8/24/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Extension)
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;
@end
