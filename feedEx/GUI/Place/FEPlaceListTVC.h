//
//  FEPlaceListTVC.h
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FESearchSettingInfo.h"
@protocol FEPlaceListTVCDelegate<NSObject>
-(void)didSelectPlaceRow;
@end

@interface FEPlaceListTVC : UITableViewController
@property (nonatomic) BOOL isEditMode;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (strong, nonatomic) NSArray *places; // array of Places
@property (strong, nonatomic) NSArray *placesForDisplay; // array of displayed Places
@property (weak, nonatomic) id<FEPlaceListTVCDelegate> placeListDelegate;
@property (strong, nonatomic) NSString *quickSearchString;

- (void)updatePlacesWithSettingInfo:(FESearchPlaceSettingInfo *)placeSetting;
- (NSArray*)getSelectedPlaces;
- (void)setQuickSearchString:(NSString *)quickSearchString withAnimated:(BOOL)animated;
- (void)setSelectAll:(BOOL)selectAll;
@end
