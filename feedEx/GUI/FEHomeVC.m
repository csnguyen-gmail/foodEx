//
//  FEHomeVC.m
//  feedEx
//
//  Created by csnguyen on 6/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEHomeVC.h"
#import "FEPlaceEditMainVC.h"
#import "FECoreDataController.h"
#import "Place.h"
@interface FEHomeVC ()

@end

@implementation FEHomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addPlace"]) {
        UINavigationController *navigation = [segue destinationViewController];
        FEPlaceEditMainVC *addPlaceInfoMainVC = navigation.viewControllers[0];
        addPlaceInfoMainVC.placeInfo = nil;
    }
}
@end
