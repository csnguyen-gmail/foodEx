//
//  FEPlaceListTVC.h
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEPlaceDataSource.h"

@interface FEPlaceListTVC : UITableViewController
@property (strong, nonatomic) FEPlaceDataSource *placeDataSource;
@property (nonatomic) BOOL isEditMode;
@end
