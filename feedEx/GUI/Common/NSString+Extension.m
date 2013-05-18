//
//  NSString+Extension.m
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)
- (void)drawCenteredInRect:(CGRect)rect withFont:(UIFont *)font {
    CGSize size = [self sizeWithFont:font];
    
    CGRect textBounds = CGRectMake(rect.origin.x + (rect.size.width - size.width) / 2,
                                   rect.origin.y + (rect.size.height - size.height) / 2,
                                   size.width, size.height);
    [self drawInRect:textBounds withFont:font];
}

@end
