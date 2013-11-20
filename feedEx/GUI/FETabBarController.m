//
//  FETabBarController.m
//  feedEx
//
//  Created by csnguyen on 8/28/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETabBarController.h"
#import <CoreData/CoreData.h>
#import "FECoreDataController.h"
#import "Place.h"
#import "FEDataSerialize.h"
#import "UIAlertView+Extension.h"
#import "Common.h"

@interface FETabBarController ()<UIAlertViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) NSURL *url;
@property (weak, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL updatingLocation;
@end
#define COMFIRM_DLG 0
#define FINISH_DLG 1
@implementation FETabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    // have to get persistentStoreCoordinator on main thread
    self.persistentStoreCoordinator = [[FECoreDataController sharedInstance] persistentStoreCoordinator];
    // tracking Coredata change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    self.updatingLocation = NO;

}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
}

#pragma mark - getter setter
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}
// location update handler
- (void)updateLocation {
    if (self.updatingLocation) {
        return;
    }
    self.updatingLocation = YES;
    [self.locationManager startUpdatingLocation];
}
#define ALLOW_PERIOD_FROM_LAST_UPDATE 10.0 // second
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < ALLOW_PERIOD_FROM_LAST_UPDATE) {
        self.updatingLocation = NO;
        [self.locationManager stopUpdatingLocation];
        self.currentLocation = location;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATED
                                                                object:nil userInfo:@{@"location":location}];
        }];
    }
}
// core data update handler
- (void)handleDataModelChanged:(NSNotification *)note {
    NSManagedObjectContext *context = (NSManagedObjectContext *)note.object;
    // distingush to another context updating
    if(context.persistentStoreCoordinator == self.persistentStoreCoordinator) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CORE_DATA_UPDATED
                                                                object:nil userInfo:@{@"note":note}];
        }];
    }
}

// receive new mail from other User handler
- (void)showReceiveMailComfirmWithUrl:(NSURL *)url{
    self.url = url;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Do you want import new Places?"
                                                       delegate:self cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    alertView.tag = COMFIRM_DLG;
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == COMFIRM_DLG) {
        // YES button
        if (buttonIndex == 1) {
            // show loading alert
            UIAlertView *loadingAlertView = [UIAlertView indicatorAlertWithTitle:nil message:@"Importing data to database..."];
            [loadingAlertView show];
            // start thread
            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
            [operationQueue addOperationWithBlock:^{
                NSDictionary *placeInfo = [FEDataSerialize deserializeMailData:[NSData dataWithContentsOfURL:self.url]];
                NSMutableString *body;
                NSString *tilte;
                if (placeInfo) {
                    User *user = placeInfo[USER_KEY];
                    tilte = [NSString stringWithFormat:@"Received from %@", user.name];
                    body = [[NSMutableString alloc] initWithString:@"Import finshed!"];
                    NSArray *places = placeInfo[PLACES_KEY];
                    for (Place *place in places) {
                        [body appendFormat:@"\n%@", place.name];
                    }
                    
                } else {
                    tilte = @"Error";
                    body = [[NSMutableString alloc] initWithString:@"Importing data is not suitable"];
                }
                [loadingAlertView dismissWithClickedButtonIndex:0 animated:NO];
                UIAlertView *resultAlert = [[UIAlertView alloc] initWithTitle:tilte
                                                                      message:body
                                                                     delegate:self cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                resultAlert.tag = FINISH_DLG;
                [resultAlert show];
            }];
        }
    }
}
@end
