//
//  FETabBarController.h
//  feedEx
//
//  Created by csnguyen on 8/28/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FETabBarController : UITabBarController
@property (nonatomic, strong) CLLocation *currentLocation;
- (void)showReceiveMailComfirmWithUrl:(NSURL *)url;
- (void)updateLocation;
@end
