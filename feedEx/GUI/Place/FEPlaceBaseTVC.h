//
//  FEPlaceBaseTVC.h
//  feedEx
//
//  Created by csnguyen on 7/1/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FESearchSettingInfo.h"
#import <CoreLocation/CoreLocation.h>

// TODO: will be replace by FEPlaceDataSource
@interface FEPlaceBaseTVC : UITableViewController
@property (strong, nonatomic) FESearchPlaceSettingInfo *placeSetting;
@property (strong, nonatomic) NSArray *places; // array of Places
@property (strong, nonatomic) CLLocation *currentLocation;

- (void)didChangeDataSource; // optional abstract function
@end
