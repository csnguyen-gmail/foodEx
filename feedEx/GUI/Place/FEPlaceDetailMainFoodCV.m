//
//  FEPlaceDetailMainFoodCV.m
//  feedEx
//
//  Created by csnguyen on 11/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceDetailMainFoodCV.h"

@implementation FEPlaceDetailMainFoodCV
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.touchDelegate touchBegin];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self.touchDelegate touchEnd];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.touchDelegate touchEnd];
}
@end
