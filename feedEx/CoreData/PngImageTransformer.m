//
//  PngImageTransformer.m
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "PngImageTransformer.h"

@implementation PngImageTransformer

+ (Class)transformedValueClass {
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

// Takes a UIImage and returns NSData
- (id)transformedValue:(id)value {
    return UIImagePNGRepresentation(value);
}

// Takes NSData from Core Data and returns a UIImage
- (id)reverseTransformedValue:(id)value {
    return [UIImage imageWithData:value];
}@end
