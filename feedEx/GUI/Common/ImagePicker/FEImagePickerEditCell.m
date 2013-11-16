//
//  FEImagePickerEditCell.m
//  NewImagePicker
//
//  Created by csnguyen on 11/14/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerEditCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FEImagePickerEditCell
- (void)awakeFromNib {
    self.effectImageView.layer.cornerRadius = 10.0;
    self.effectImageView.layer.masksToBounds = YES;
    self.effectImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}
- (void)setSelectedStyle:(BOOL)selected {
    self.effectImageView.layer.borderWidth = selected ? 2.0 : 0.0;
}
@end
