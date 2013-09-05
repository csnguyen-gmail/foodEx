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

@interface FEPlaceDataSource()
@property (weak, nonatomic) FECoreDataController *coreData;
@end

@implementation FEPlaceDataSource
- (void)queryPlaceInfoWithSetting:(FESearchPlaceSettingInfo *)placeSetting{
    self.places = [Place placesFromPlaceSettingInfo:self.placeSetting withMOC:self.coreData.managedObjectContext];
}
#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
@end
