//
//  FEHomeVC.m
//  feedEx
//
//  Created by csnguyen on 6/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEHomeVC.h"
#import <QuartzCore/QuartzCore.h>
#import "FECoreDataController.h"
#import "Place+Extension.h"
#import "Address.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UIAlertView+Extension.h"
@interface FEHomeVC ()<UIAlertViewDelegate>
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *homeButtons;
@end

@implementation FEHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIButton *button in self.homeButtons) {
        button.layer.cornerRadius = 10.0;
        button.layer.masksToBounds = YES;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        self.view = nil;
    }
}

#pragma mark - event handler
#define AUTOFILL_CONFIRM_TAG 0
- (IBAction)autoFillAddress:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want auto fill empty address?"
                                                       delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = AUTOFILL_CONFIRM_TAG;
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AUTOFILL_CONFIRM_TAG) {
        if (buttonIndex == 1) {
            NSArray *places = [Place placesWithEmptyAddress];
            if (places.count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"There is no Place need update address!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            UIAlertView *updatingAlertView = [UIAlertView indicatorAlertWithTitle:nil message:@"Updating..."];
            [updatingAlertView show];
            
            __block int count = 0;
            for (Place *place in places) {
                CLLocationCoordinate2D location = {[place.address.lattittude doubleValue], [place.address.longtitude doubleValue]};
                [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location completionHandler:^(GMSReverseGeocodeResponse *resp, NSError *error) {
                    if (resp.firstResult != nil) {
                        place.address.address = [NSString stringWithFormat:@"%@, %@", resp.firstResult.addressLine1, resp.firstResult.addressLine2];
                    }
                    // finish getting address
                    if (++count == places.count) {
                        [[FECoreDataController sharedInstance] saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
                            [updatingAlertView dismissWithClickedButtonIndex:0 animated:YES];
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Finish!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                            [alertView show];
                        }];
                    }
                }];
            }
        }
    }
}
@end
