//
//  FEHomeVC.m
//  feedEx
//
//  Created by csnguyen on 6/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEHomeVC.h"
#import "FEEditPlaceInfoMainVC.h"
#import "Place.h"
@interface FEHomeVC ()

@end

@implementation FEHomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addPlace"]) {
        FEEditPlaceInfoMainVC *addPlaceInfoMainVC = [segue destinationViewController];
        addPlaceInfoMainVC.editPlaceInfo = nil;
    }
    else if ([[segue identifier] isEqualToString:@"editPlace"]) {
        FEEditPlaceInfoMainVC *editPlaceInfoMainVC = [segue destinationViewController];
        editPlaceInfoMainVC.editPlaceInfo = [[Place alloc] init];
        // TODO
    }
}


@end
