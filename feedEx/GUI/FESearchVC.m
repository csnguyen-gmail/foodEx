//
//  FESearchVC.m
//  feedEx
//
//  Created by csnguyen on 6/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchVC.h"
#import "FEPlaceListTVC.h"
#import "FEPlaceGridCVC.h"
#import "FESearchSettingInfo.h"
#import "FESearchSettingVC.h"
#import <CoreLocation/CoreLocation.h>

#define PLACE_DISP_TYPE @"PlaceDispType"
@interface FESearchVC()<FESearchSettingVCDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) FEPlaceListTVC *placeListTVC;
@property (weak, nonatomic) FEPlaceGridCVC *placeGridCVC;
@property (nonatomic, strong) FESearchSettingInfo *searchSettingInfo;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dispTypeSC;
@property (nonatomic) NSUInteger placeDispType; // List or Grid
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *placeListView;
@property (weak, nonatomic) IBOutlet UIView *placeGridView;
@end

@implementation FESearchVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.placeListTVC.placeSetting = self.searchSettingInfo.placeSetting;
    // TODO
    [self loadPlaceDisplayType];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}
- (void)loadPlaceDisplayType {
    _placeDispType = [[NSUserDefaults standardUserDefaults] integerForKey:PLACE_DISP_TYPE];
    [self switchPlaceDispToType:self.placeDispType withAnimation:NO];
}
- (void)setPlaceDispType:(NSUInteger)placeDispType {
    _placeDispType = placeDispType;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:placeDispType forKey:PLACE_DISP_TYPE];
    [defaults synchronize];
}
- (void)switchPlaceDispToType:(NSUInteger)type withAnimation:(BOOL)animated{
    UIView *shownView = (type == 0) ? self.placeListView : self.placeGridView;
    UIView *hiddenView = (type == 0) ? self.placeGridView : self.placeListView;
    if (animated) {
        [UIView transitionWithView:self.mainView
                          duration:0.4
                           options:(type == 0) ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                        animations: ^{
                            shownView.hidden = NO;
                            hiddenView.hidden = YES;
                        }
                        completion:^(BOOL finished) {
                        }];
    }
    else {
        shownView.hidden = NO;
        hiddenView.hidden = YES;
    }
    self.dispTypeSC.selectedSegmentIndex = type;
}
#pragma mark - action handler
- (IBAction)showTypeChange:(UISegmentedControl *)sender {
    self.placeDispType = sender.selectedSegmentIndex;
    [self switchPlaceDispToType:sender.selectedSegmentIndex withAnimation:YES];
}
#pragma mark - getter setter
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}
- (FESearchSettingInfo *)searchSettingInfo {
    if (!_searchSettingInfo) {
        NSData *archivedObject = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_SETTING_KEY];
        if (archivedObject) {
            _searchSettingInfo = (FESearchSettingInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
        }
        else {
            _searchSettingInfo = [[FESearchSettingInfo alloc] init];
            _searchSettingInfo.placeSetting = [[FESearchPlaceSettingInfo alloc] init];
            _searchSettingInfo.foodSetting = [[FESearchFoodSettingInfo alloc] init];
        }
        
    }
    return _searchSettingInfo;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeList"]) {
        self.placeListTVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"placeGrid"]) {
        self.placeGridCVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:[[FESearchSettingVC class] description]]) {
        FESearchSettingVC *searchSettingVC = [segue destinationViewController];
        searchSettingVC.delegate = self;
    }
}
#pragma mark - FESearchSettingVCDelegate
- (void)didFinishSearchSetting:(FESearchSettingInfo *)searchSetting hasModification:(BOOL)hasModification {
    if (hasModification) {
        self.searchSettingInfo = searchSetting;
        self.placeListTVC.placeSetting = self.searchSettingInfo.placeSetting;
    }
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationManager:manager didUpdateLocations:@[oldLocation, newLocation]];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.placeListTVC.currentLocation = [locations lastObject];
    [manager stopUpdatingLocation];
}
@end
