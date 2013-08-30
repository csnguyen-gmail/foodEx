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

@interface FETabBarController ()<UIAlertViewDelegate>
@property (nonatomic, strong) NSURL *url;
@property (weak, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (weak, nonatomic) FECoreDataController *coreData;
@end
#define COMFIRM_DLG 0
#define LOADING_DLG 1
#define FINISH_DLG 2
@implementation FETabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    // have to get persistentStoreCoordinator on main thread
    self.persistentStoreCoordinator = self.coreData.persistentStoreCoordinator;
    // tracking Coredata change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChange:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];

}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];

}
- (void)handleDataModelChange:(NSNotification *)note {
    NSManagedObjectContext *context = (NSManagedObjectContext *)note.object;
    // distingush to another context updating
    if(context.persistentStoreCoordinator == self.persistentStoreCoordinator) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            for (UIViewController* vc in self.viewControllers) {
                UIViewController *topVC = vc;
                if ([vc isKindOfClass:[UINavigationController class]]) {
                    topVC = [(UINavigationController*)vc topViewController];
                }
                if ([topVC respondsToSelector:@selector(handleDataModelChange:)]) {
                    [topVC performSelector:@selector(handleDataModelChange:) withObject:note];
                }
            }
        }];
    }
}

#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}

- (void)showReceiveMailComfirmWithUrl:(NSURL *)url{
    self.url = url;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Do you want import new Places?"
                                                       delegate:self cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    alertView.tag = COMFIRM_DLG;
    [alertView show];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == COMFIRM_DLG) {
        // YES button
        if (buttonIndex == 1) {
            // show loading alert
            UIAlertView *loadingAlertView = [UIAlertView indicatorAlertWithTitle:nil
                                                                         message:@"Importing data to database..."
                                                                        delegate:nil];
            loadingAlertView.tag = LOADING_DLG;
            [loadingAlertView show];
            // start thread
            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
            [operationQueue addOperationWithBlock:^{
                NSDictionary *placeInfo = [FEDataSerialize deserializePlaces:[NSData dataWithContentsOfURL:self.url]];
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
