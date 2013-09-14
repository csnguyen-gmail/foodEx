//
//  FEFoodDetailVC.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodDetailVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FEFlipFoodView.h"
@interface FEFoodDetailVC()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet FEFlipFoodView *flipFoodView;
@end
@implementation FEFoodDetailVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgView.layer.cornerRadius = 10.0;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.bgView.layer.borderWidth = 1.5;
    // set up flip view
    self.flipFoodView.name = self.food.name;
    self.flipFoodView.isBest = [self.food.isBest boolValue];
    [self.flipFoodView setDatasource:[self.food.photos array] withSelectedIndex:0];

}
- (void)close {
    [UIView transitionWithView:self.parentViewController.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.view removeFromSuperview];
                    } completion:^(BOOL finished) {
                        [self removeFromParentViewController];
                    }];
}

#pragma mark -handler
- (IBAction)closeTapped:(UIButton *)sender {
    [self close];
}

@end
