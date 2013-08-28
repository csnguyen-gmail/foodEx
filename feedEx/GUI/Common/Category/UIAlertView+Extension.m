//
//  UIAlertView+Extension.m
//  feedEx
//
//  Created by csnguyen on 8/28/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "UIAlertView+Extension.h"

@implementation UIAlertView (Extension)
+ (UIAlertView *)indicatorAlertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [alertView addSubview:spinner];
    [spinner startAnimating];
    return alertView;
}
@end
