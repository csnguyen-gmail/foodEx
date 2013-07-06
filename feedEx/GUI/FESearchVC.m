//
//  FESearchVC.m
//  feedEx
//
//  Created by csnguyen on 6/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchVC.h"
#import "FEPlaceListTVC.h"
#import "FESearchSettingInfo.h"
#import "FESearchSettingVC.h"
#import <CoreLocation/CoreLocation.h>

@interface FESearchVC()<FESearchSettingVCDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *placeHolderView;
@property (weak, nonatomic) FEPlaceListTVC *placeListView;
@property (nonatomic, strong) FESearchSettingInfo *searchSettingInfo;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation FESearchVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    // TODO
    self.placeListView.view.frame = CGRectOffset(self.placeListView.view.frame, 0, -20);
    self.placeListView.placeSetting = self.searchSettingInfo.placeSetting;
    [self addChildViewController:self.placeListView];
    [self.placeHolderView addSubview:self.placeListView.view];
    [self showViewByType:0]; // TODO
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.locationManager startUpdatingLocation];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}
#pragma mark - action handler
- (IBAction)showTypeChange:(UISegmentedControl *)sender {
    [self showViewByType:sender.selectedSegmentIndex];
}
- (void)showViewByType:(NSInteger)type {
    // TODO
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
- (FEPlaceListTVC *)placeListView {
    if (!_placeListView) {
        _placeListView = [self.storyboard instantiateViewControllerWithIdentifier:[[FEPlaceListTVC class] description]];
    }
    return _placeListView;
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
    if ([[segue identifier] isEqualToString:[[FESearchSettingVC class] description]]) {
        FESearchSettingVC *searchSettingVC = [segue destinationViewController];
        searchSettingVC.delegate = self;
    }
}
#pragma mark - FESearchSettingVCDelegate
- (void)didFinishSearchSetting:(FESearchSettingInfo *)searchSetting hasModification:(BOOL)hasModification {
    if (hasModification) {
        self.searchSettingInfo = searchSetting;
        self.placeListView.placeSetting = self.searchSettingInfo.placeSetting;
    }
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationManager:manager didUpdateLocations:@[oldLocation, newLocation]];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.placeListView.currentLocation = [locations lastObject];
    [manager stopUpdatingLocation];
}
@end
