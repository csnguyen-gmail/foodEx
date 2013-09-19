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
@interface FEHomeVC ()<UIAlertViewDelegate>
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *homeButtons;
@property (weak, nonatomic) FECoreDataController *coreData;
@end

@implementation FEHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIButton *button in self.homeButtons) {
        button.layer.cornerRadius = 10.0;
        button.layer.masksToBounds = YES;
    }
}
#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
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
            NSArray *places = [Place placesWithEmptyAddress:self.coreData.managedObjectContext];
            if (places.count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"There is no Place need update address!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            UIAlertView *updatingAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Updating..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
            [spinner startAnimating];
            [updatingAlertView addSubview:spinner];
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
                        [self.coreData saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
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
