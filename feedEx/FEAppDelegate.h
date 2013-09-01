//
//  FEAppDelegate.h
//  feedEx
//
//  Created by csnguyen on 4/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NTF_APP_WILL_RESIGN_ACTIVE @"applicationWillResignActive"

@interface FEAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
- (void)startObservingFirstResponder;
- (void)stopObservingFirstResponder;
- (void)updateLocation;
@end
