//
//  FEFoodDetailVC.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodDetailVC.h"
#import <QuartzCore/QuartzCore.h>
@interface FEFoodDetailVC()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@end
@implementation FEFoodDetailVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgView.layer.cornerRadius = 10.0;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.bgView.layer.borderWidth = 1.5;
}
- (IBAction)closeTapped:(UIButton *)sender {
    // TODO
    [self.delegate exitFoodDetailAtIndes:0];
}

@end
