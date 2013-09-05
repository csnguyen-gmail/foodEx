//
//  FEPlaceDataSource.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FESearchSettingInfo.h"

@interface FEPlaceDataSource : NSObject
@property (strong, nonatomic) FESearchPlaceSettingInfo *placeSetting;
@property (strong, nonatomic) NSArray *places; // array of Places

- (void)queryPlaceInfoWithSetting:(FESearchPlaceSettingInfo *)placeSetting;
@end
