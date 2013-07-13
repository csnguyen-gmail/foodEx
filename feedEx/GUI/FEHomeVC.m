//
//  FEHomeVC.m
//  feedEx
//
//  Created by csnguyen on 6/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEHomeVC.h"
#import "FEEditPlaceInfoMainVC.h"
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

- (IBAction)addPlace:(UIButton *)sender {
    UINavigationController *editPlaceNav = [self.storyboard instantiateViewControllerWithIdentifier:@"editPlaceNavigation"];
    FEEditPlaceInfoMainVC *addPlaceInfoMainVC = editPlaceNav.viewControllers[0];
    addPlaceInfoMainVC.placeInfo = nil;
    [self presentModalViewController:editPlaceNav animated:YES];
}

@end
