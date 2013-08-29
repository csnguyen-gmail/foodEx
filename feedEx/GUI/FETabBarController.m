//
//  FETabBarController.m
//  feedEx
//
//  Created by csnguyen on 8/28/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETabBarController.h"
#import "FESearchVC.h"
#import "FEMapVC.h"
#import <CoreData/CoreData.h>
#import "Place.h"
#import "FEDataSerialize.h"
#import "UIAlertView+Extension.h"

@interface FETabBarController ()<UIAlertViewDelegate>
@property (nonatomic, weak) FESearchVC *searchVC;
@property (nonatomic, weak) FEMapVC *mapVC;
@property (nonatomic, strong) NSURL *url;
@end
#define COMFIRM_DLG 0
#define LOADING_DLG 1
#define FINISH_DLG 2
@implementation FETabBarController


- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationController *searchNC = self.childViewControllers[1];
    self.searchVC = searchNC.childViewControllers[0];
    self.mapVC = self.childViewControllers[2];
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
        else {
            
        }
    }
    else {
        
    }
    
}
@end
