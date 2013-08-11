//
//  FEPlaceListSearchMapTVC.h
//  feedEx
//
//  Created by csnguyen on 8/11/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
@protocol FEPlaceListSearchMapTVCDelegate<NSObject>
- (void)searchMapDidSelectPlace:(Place*)place;
@end
@interface FEPlaceListSearchMapTVC : UITableViewController
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, weak) id<FEPlaceListSearchMapTVCDelegate> searchDelegate;
@end
