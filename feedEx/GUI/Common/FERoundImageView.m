//
//  FERoundImageView.m
//  feedEx
//
//  Created by csnguyen on 7/6/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FERoundImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FERoundImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return  self;
}
- (void)setup {
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
//    self.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.layer.borderWidth = 1.5;
    
//    // drop shadow
//    [self.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.layer setShadowOpacity:1];
//    [self.layer setShadowRadius:2.0];
//    [self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
}
@end
