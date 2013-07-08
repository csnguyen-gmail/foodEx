//
//  FEPlaceListCell.m
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListCell.h"

@implementation FEPlaceListCell

- (IBAction)informationBtnTapped:(UIButton *)sender {
    [self.delegate didSelectPlaceDetailAtCell:self];
}

@end
