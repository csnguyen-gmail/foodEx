//
//  FEPlaceDataSource.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FESearchSettingInfo.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationUpdateCompletionBlock)(CLLocation*);
typedef void (^PlaceUpdateCompletionBlock)(CLLocation*);

@interface FEPlaceDataSource : NSObject
@property (strong, nonatomic) FESearchPlaceSettingInfo *placeSetting;
@property (strong, nonatomic) NSArray *places; // array of Places
@property (strong, nonatomic) CLLocation *currentLocation;

- (void)queryPlaceInfoWithSetting:(FESearchPlaceSettingInfo *)placeSetting;
- (void)updateLocation:(LocationUpdateCompletionBlock)completion;
@end
