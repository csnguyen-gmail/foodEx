//
//  FEPlaceListSearchMapCell.m
//  feedEx
//
//  Created by csnguyen on 8/31/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListSearchMapCell.h"
@interface FEPlaceListSearchMapCell()
@property (weak, nonatomic) IBOutlet UIButton *routeBtn;
@end
@implementation FEPlaceListSearchMapCell
- (void)awakeFromNib {
    self.routeBtn.layer.cornerRadius = 10;
    self.routeBtn.layer.masksToBounds = YES;
}
- (IBAction)routeBtnTapped:(UIButton *)sender {
    [self.delegate didSelectPlaceDetailAtCell:self];
}

@end
