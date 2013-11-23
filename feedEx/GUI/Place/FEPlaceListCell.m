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
    self.editButton.layer.cornerRadius = 5.0;
    self.editButton.layer.masksToBounds = YES;
}

- (IBAction)informationBtnTapped:(UIButton *)sender {
    [self.delegate didSelectPlaceDetailAtCell:self];
}
- (IBAction)editBtnTapped:(UIButton *)sender {
    [self.delegate didSelectPlaceDetailAtCell:self];
}
- (void)toggleDetailButton {
    self.informationBtn.hidden = !self.informationBtn.hidden;
    self.editButton.hidden = !self.editButton.hidden;
}
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    self.informationBtn.hidden = _isEditMode;
    self.editButton.hidden = !_isEditMode;
}
@end
