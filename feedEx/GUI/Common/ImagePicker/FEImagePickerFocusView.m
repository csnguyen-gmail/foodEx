//
//  FEImagePickerFocusView.m
//  NewImagePicker
//
//  Created by csnguyen on 11/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerFocusView.h"
#import <QuartzCore/QuartzCore.h>


@implementation FEImagePickerFocusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:10.0];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        CABasicAnimation* selectionAnimation = [CABasicAnimation
                                                animationWithKeyPath:@"borderColor"];
        selectionAnimation.toValue = (id)[UIColor darkGrayColor].CGColor;
        selectionAnimation.repeatCount = 12;
        [self.layer addAnimation:selectionAnimation
                          forKey:@"selectionAnimation"];

    }
    return self;
}
@end
