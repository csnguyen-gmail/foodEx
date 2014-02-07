//
//  FEPlaceDetailTVC.h
//  feedEx
//
//  Created by csnguyen on 7/28/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
@protocol FEPlaceDetailTVCDelegate<NSObject>
- (void)didSelectFood:(Food*)food;
@end

@interface FEPlaceDetailTVC : UITableViewController
@property (nonatomic, strong) Place *place;
@property (nonatomic, weak) id<FEPlaceDetailTVCDelegate> placeDetailTVCDelegate;
@end
