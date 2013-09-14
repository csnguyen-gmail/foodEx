//
//  FETransparentCustomSegue.m
//  feedEx
//
//  Created by csnguyen on 9/14/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETransparentCustomSegue.h"

@implementation FETransparentCustomSegue
- (void)perform {
    UIViewController *sourceVC = self.sourceViewController;
    UIViewController *destVC = self.destinationViewController;
    destVC.view.frame = sourceVC.view.frame;
    destVC.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    [sourceVC addChildViewController:destVC];
    [UIView transitionWithView:sourceVC.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [sourceVC.view addSubview:destVC.view];
                    } completion:^(BOOL finished) {
                        
                    }];
}
@end
