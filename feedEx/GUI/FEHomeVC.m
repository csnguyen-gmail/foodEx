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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addPlace"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        FEEditPlaceInfoMainVC *addPlaceInfoMainVC = navigationController.viewControllers[0];
        addPlaceInfoMainVC.placeId = nil;
    }
    else if ([[segue identifier] isEqualToString:@"editPlace"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        FEEditPlaceInfoMainVC *editPlaceInfoMainVC = navigationController.viewControllers[0];
        
        FECoreDataController *coreData = [FECoreDataController sharedInstance];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:coreData.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects) {
            Place *place = [fetchedObjects lastObject];
            editPlaceInfoMainVC.placeId = [place objectID];
        }
    }
}


@end
