//
//  FEUserListCell.m
//  feedEx
//
//  Created by csnguyen on 9/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEUserListCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FEUserListCell
- (void)awakeFromNib {
    self.userImageView.layer.cornerRadius = 10.0;
    self.userImageView.layer.masksToBounds = YES;
}

@end
