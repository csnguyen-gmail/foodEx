//
//  FEImageEditorCell.m
//  feedEx
//
//  Created by csnguyen on 11/3/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImageEditorCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FEImageEditorCell
- (void)awakeFromNib {
    self.effectImageView.layer.cornerRadius = 10.0;
    self.effectImageView.layer.masksToBounds = YES;
//    self.effectImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    self.effectImageView.layer.borderWidth = 1.0;
}
@end
