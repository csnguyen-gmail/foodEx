//
//  PngImageTransformer.m
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "PngImageTransformer.h"

@implementation PngImageTransformer
+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSData class]])
        return value;
    
    return UIImagePNGRepresentation((UIImage *)value);
}

- (id)reverseTransformedValue:(id)value
{
    return [UIImage imageWithData:(NSData *)value];
}
@end
