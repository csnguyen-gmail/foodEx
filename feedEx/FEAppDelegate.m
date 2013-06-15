//
//  FEAppDelegate.m
//  feedEx
//
//  Created by csnguyen on 4/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEAppDelegate.h"
#import "FETrackingKeyboardWindow.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation FEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // tracking keyboard
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    FETrackingKeyboardWindow *window =[[FETrackingKeyboardWindow alloc] initWithFrame:screenRect];
    self.window = window;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    // provide key to use Google Map API
    [GMSServices provideAPIKey:@"AIzaSyAFoi1LNE9wzQbTjwX1LuPKEbvIP9WVfKA"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] postNotificationName:NTF_APP_WILL_RESIGN_ACTIVE object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
