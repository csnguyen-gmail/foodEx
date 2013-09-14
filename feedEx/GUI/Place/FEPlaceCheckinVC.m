//
//  FEPlaceCheckinVC.m
//  feedEx
//
//  Created by csnguyen on 9/14/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceCheckinVC.h"
#import "FEFlipPlaceView.h"
#import <QuartzCore/QuartzCore.h>
#import "FEAppDelegate.h"
#import "Common.h"
#import "Place+Extension.h"
#import "FECoreDataController.h"

@interface FEPlaceCheckinVC ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet FEFlipPlaceView *flipPlaceView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UIButton *checkinBtn;
@property (strong, nonatomic) Place *place;
@property (weak, nonatomic) FECoreDataController *coreData;
@end

@implementation FEPlaceCheckinVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkinBtn.enabled = NO;
    self.checkinBtn.layer.cornerRadius = 10.0;
    self.checkinBtn.layer.masksToBounds = YES;
    self.bgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    self.bgView.layer.cornerRadius = 10.0;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.bgView.layer.borderWidth = 1.5;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:)
                                                 name:LOCATION_UPDATED object:nil];

    // update location
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate updateLocation];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_UPDATED object:nil];
}
#define NO_PLACE_TAG 1
#define TIME_INVALID_TAG 2
#define ACCEPTABLE_CHECKIN_PERIOD 60*15 // 15 minutes
- (void)locationChanged:(NSNotification *)info {
    CLLocation* location = [info userInfo][@"location"];
    NSArray *nearestPlaces = [Place placesNearestLocation:location withMOC:self.coreData.managedObjectContext];
    if (nearestPlaces.count > 0) {
        Place* place = nearestPlaces[0];
        self.flipPlaceView.name = place.name;
        self.flipPlaceView.rating = [place.rating integerValue];
        [self.flipPlaceView setDatasource:[place.photos array] withSelectedIndex:0];
        NSDate *now = [NSDate date];
        NSTimeInterval timeDistance = [now timeIntervalSinceDate:place.lastTimeCheckin];
        if (timeDistance < ACCEPTABLE_CHECKIN_PERIOD) {
            NSString *message = [NSString stringWithFormat:@"You've just checked in %d minutes early.", (int)(timeDistance / 60)];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message
                                                               delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            alertView.tag = TIME_INVALID_TAG;
            [alertView show];
        }
        else {
            self.checkinBtn.enabled = YES;
            self.place = place;
        }
    }
    // there is no Place arround here
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"There is no Place around here."
                                                           delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        alertView.tag = NO_PLACE_TAG;
        [alertView show];
    }
    [self.indicatorView stopAnimating];
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
#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}

#pragma mark -handler
- (IBAction)closeTapped:(UIButton *)sender {
    [self close];
}
- (IBAction)checkinTapped:(id)sender {
    self.place.lastTimeCheckin = [NSDate date];
    self.place.timesCheckin = @([self.place.timesCheckin integerValue] + 1);
    [self.coreData saveToPersistenceStoreAndWait];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == NO_PLACE_TAG) {
        [self close];
    }
}
@end
