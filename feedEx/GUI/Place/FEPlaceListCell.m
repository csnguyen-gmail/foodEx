//
//  FEPlaceListCell.m
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FEPlaceListCell
- (void)awakeFromNib {
    self.detailBtn.layer.cornerRadius = 5.0;
    self.detailBtn.layer.masksToBounds = YES;
}
- (IBAction)detailBtnTapped:(UIButton *)sender {
    [self.delegate didSelectPlaceDetailAtCell:self];
}

- (void)toggleDetailButton {
    self.isEditMode = !self.isEditMode;
}
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    if (isEditMode) {
        self.detailImageView.image = [UIImage imageNamed:@"compose"];
    }
    else {
        self.detailImageView.image = [UIImage imageNamed:@"watch"];
    }
}
@end
