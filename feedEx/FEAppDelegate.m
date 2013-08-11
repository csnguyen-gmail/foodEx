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
#import <CoreData/CoreData.h>
#import "FESearchVC.h"
#import "FEMapVC.h"
@interface FEAppDelegate()
@property (nonatomic, weak) FESearchVC *searchVC;
@property (nonatomic, weak) FEMapVC *mapVC;
@end

@implementation FEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // tracking keyboard
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    FETrackingKeyboardWindow *window =[[FETrackingKeyboardWindow alloc] initWithFrame:screenRect];
    self.window = window;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    UITabBarController *tabbarVC = (UITabBarController*)self.window.rootViewController;
    UINavigationController *searchNC = tabbarVC.childViewControllers[1];
    self.searchVC = searchNC.childViewControllers[0];
    self.mapVC = tabbarVC.childViewControllers[2];
    // provide key to use Google Map API
    [GMSServices provideAPIKey:@"AIzaSyAFoi1LNE9wzQbTjwX1LuPKEbvIP9WVfKA"];
    // tracking Coredata change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    return YES;
}
// tracking Text field/view change
- (void)startObservingFirstResponder {
    FETrackingKeyboardWindow *window = (FETrackingKeyboardWindow*)self.window;
    [window startObservingFirstResponder];
}
- (void)stopObservingFirstResponder {
    FETrackingKeyboardWindow *window = (FETrackingKeyboardWindow*)self.window;
    [window stopObservingFirstResponder];
}
// tracking Core data change
- (void)handleDataModelChange:(NSNotification *)note
{
    self.searchVC.needUpdateDatabase = YES;
    self.mapVC.needUpdateDatabase = YES;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:nil];
}

@end
