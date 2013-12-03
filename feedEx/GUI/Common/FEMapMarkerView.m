//
//  FEMapMarkerView.m
//  feedEx
//
//  Created by csnguyen on 11/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEMapMarkerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FEMapMarkerView
- (void)awakeFromNib {
    self.imageView.layer.cornerRadius = 10.0;
    self.imageView.layer.masksToBounds = YES;
}
@end
