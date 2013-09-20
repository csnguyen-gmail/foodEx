//
//  FEUserEditVC.m
//  feedEx
//
//  Created by csnguyen on 9/19/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEUserEditVC.h"
#import "FEUserInfoTVC.h"
#import <QuartzCore/QuartzCore.h>

@interface FEUserEditVC ()
@property (nonatomic, weak) FEUserInfoTVC* userInfoTVC;
@end

@implementation FEUserEditVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userInfoTVC.view.layer.cornerRadius = 10.0;
    self.userInfoTVC.view.layer.borderWidth = 1.0;
    self.userInfoTVC.view.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.userInfoTVC.imageBtn.layer.cornerRadius = 10.0;
    self.userInfoTVC.imageBtn.layer.borderWidth = 1.0;
    self.userInfoTVC.imageBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"userInfo"]) {
        self.userInfoTVC = [segue destinationViewController];
    }
}
- (IBAction)closeButtonTapped:(UIButton *)sender {
    [UIView transitionWithView:self.parentViewController.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.view removeFromSuperview];
                    } completion:^(BOOL finished) {
                        [self removeFromParentViewController];
                    }];

}
@end
