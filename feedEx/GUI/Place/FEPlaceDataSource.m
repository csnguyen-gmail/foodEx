//
//  FEPlaceDataSource.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceDataSource.h"
#import "FECoreDataController.h"
#import "CoredataCommon.h"
#import "Common.h"
#import "Place+Extension.h"

@interface FEPlaceDataSource()<CLLocationManagerDelegate>
@property (weak, nonatomic) FECoreDataController *coreData;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) LocationUpdateCompletionBlock locationUpdateCompletionBlock;
@end

@implementation FEPlaceDataSource
- (void)queryPlaceInfoWithSetting:(FESearchPlaceSettingInfo *)placeSetting{
    self.placeSetting = placeSetting;
    self.places = [Place placesFromPlaceSettingInfo:self.placeSetting withMOC:self.coreData.managedObjectContext];
}
- (void)updateLocation:(LocationUpdateCompletionBlock)completion {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
    self.locationUpdateCompletionBlock = completion;
}

#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    self.locationUpdateCompletionBlock(newLocation);
    [manager stopUpdatingLocation];
}
@end
