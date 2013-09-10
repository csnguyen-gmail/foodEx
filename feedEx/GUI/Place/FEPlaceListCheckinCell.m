//
//  FEPlaceListCheckinCell.m
//  feedEx
//
//  Created by csnguyen on 9/9/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListCheckinCell.h"

@implementation FEPlaceListCheckinCell
- (IBAction)informationBtnTapped:(UIButton *)sender {
    [self.delegate didSelectPlaceDetailAtCell:self];
}

@end
