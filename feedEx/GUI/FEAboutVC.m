//
//  FEAboutVC.m
//  feedEx
//
//  Created by csnguyen on 10/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEAboutVC.h"
#import <QuartzCore/QuartzCore.h>
#import <GoogleMaps/GoogleMaps.h>

@interface FEAboutVC ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation FEAboutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.layer.cornerRadius = 10.0;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.textView.layer.borderWidth = 1.5;
    NSMutableString *about = [NSMutableString string];
    // TODO
    [about appendFormat:@"Author: %@\n", @"Chu Si Nguyen"];
    [about appendFormat:@"Email: %@\n", @"chusinguyen108@gmail.com"];
    [about appendFormat:@"Version: %@\n", @"1.0"];
    [about appendString:@"-------------------------------------------\n"];
    [about appendString:@"Open source information\n"];
    [about appendFormat:@"・iOS Image Editor\n%@\n", @"https://github.com/heitorfr/ios-image-editor#license"];
    [about appendFormat:@"・DYRateView\n%@\n", @"https://github.com/dyang/DYRateView/blob/master/LICENSE"];
    [about appendFormat:@"・CPTextViewPlaceholder\n%@\n", @"https://github.com/abc4715760/TelecomProperty-1-2/blob/master/TelecomProperty/CPTextViewPlaceholder.m"];
    [about appendFormat:@"・ActionSheetPicker\n%@\n", @"https://github.com/TimCinel/ActionSheetPicker/blob/master/LICENSE"];
    [about appendFormat:@"・Google Maps SDK for iOS\n%@\n", [GMSServices openSourceLicenseInfo]];
    self.textView.text = about;
    
}
- (IBAction)close:(id)sender {
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
