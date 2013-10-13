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
    UIViewController *sourceVC = self.sourceVC == nil ? self.sourceViewController : self.sourceVC;
    UIViewController *destVC = self.destinationViewController;
    destVC.view.frame = sourceVC.view.frame;
    CGFloat r, g, b, a;
    [destVC.view.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    destVC.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:0.4];
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
