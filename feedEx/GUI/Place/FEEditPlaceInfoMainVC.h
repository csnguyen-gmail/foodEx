//
//  FEEditPlaceInfoMainVC.h
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "FEEditPlaceInfoTVC.h"
#import "FEVerticalResizeControllView.h"

@interface FEEditPlaceInfoMainVC : UIViewController<FEVerticalResizeControllProtocol>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FEVerticalResizeControllView *verticalResizeView;
@property (weak, nonatomic) FEEditPlaceInfoTVC *editPlaceInfoTVC;

@end