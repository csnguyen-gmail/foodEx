//
//  feedExTests.m
//  feedExTests
//
//  Created by csnguyen on 4/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "feedExTests.h"
#import "FECoreDataController.h"
#import "User.h"
#import "Place.h"
#import "Food.h"
#import "Photo.h"
#import "UIImage+Extension.h"
#import "AbstractInfo+Extension.h"

@implementation feedExTests{
    FECoreDataController *_coredata;
}

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    _coredata = [[FECoreDataController alloc] init];
    NSManagedObjectContext *context = _coredata.managedObjectContext;
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    user.name = @"UserA";
    [user insertThumbnailAndOriginImage:[UIImage imageNamed:@"a.jpg"] atIndex:0];
    for (int i = 0; i < 10; i++) {
        Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = [NSString stringWithFormat:@"Place%d", i];
        place.userOwner = user;
        for (int j = 0; j < 2; j++) {
            Food *food = [NSEntityDescription insertNewObjectForEntityForName:@"Food" inManagedObjectContext:context];
            food.name = [NSString stringWithFormat:@"Food%d_%d", i, j];
            food.isBest = @(j%2==0);
            food.placeOwner = place;
        }
    }
}

- (void)tearDown
{
    // Tear-down code here.
    [[NSFileManager defaultManager] removeItemAtURL:_coredata.storeURL error:nil];
    [super tearDown];
}

#pragma mark - CoreData test;
- (void)testSaveToPersistenceStoreAndWait {
    NSError *error = [_coredata saveToPersistenceStoreAndWait];
    STAssertNil(error, @"SaveToPersistenceStoreAndWait failed");
}
- (void)testGetUser
{
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestTemplateForName:@"GetUser"];
    NSArray *users = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (users.count == 1) {
        User *user = users.lastObject;
        if (![user.name isEqualToString:@"UserA"]) {
            STFail(@"User name doesn't match");
        }
    }
    else {
        STFail(@"Number of User doesn't correct");
    }
}
- (void)testGetPlaceByUserName
{
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestFromTemplateWithName:@"GetPlaceByUserName"
                                                                            substitutionVariables:@{@"NAME":@"UserA"}];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
    NSArray *places = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (places.count == 10) {
        for (int i = 0; i < 10; i++) {
            Place *place = places[i];
            if (![place.name isEqualToString:[NSString stringWithFormat:@"Place%d", i]]) {
                STFail(@"User name doesn't match");
                break;
            }
        }
    }
    else {
        STFail(@"Number of Place doesn't correct");
    }
}
- (void)testBestFoodOfPlace {
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestFromTemplateWithName:@"GetPlaceByUserName"
                                                                            substitutionVariables:@{@"NAME":@"UserA"}];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
    NSArray *places = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    Place *place = places[0];
    NSArray *bestFoods = [place valueForKeyPath:@"bestFoods"];
    if (bestFoods.count == 1) {
        Food *food = bestFoods.lastObject;
        if ([food.isBest isEqual: @(NO)]) {
            STFail(@"Food is not best");
        }
    }
    else {
        STFail(@"There is no best food of place");
    }
}
- (void)testBestFoodOfUser {
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestTemplateForName:@"GetUser"];
    NSArray *users = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    User *user = users.lastObject;
    NSArray *bestFoods = [user valueForKeyPath:@"bestFoods"];
    if (bestFoods.count == 10) {
        for (Food *food in bestFoods) {
            if ([food.isBest isEqual: @(NO)]) {
                STFail(@"Food is not best");
                break;
            }
        }
    }
    else {
        STFail(@"There is no best food of place");
    }
}
- (void)testSetThumbnailAndOriginImage {
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestTemplateForName:@"GetUser"];
    NSArray *users = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    User *user = users.lastObject;
    UIImage *loadedImage = [UIImage imageNamed:@"a.jpg"];
    Photo *firstPhotoOfUser = [user.photos objectAtIndex:0];
    // check origin Photo
    NSData *originData = UIImagePNGRepresentation(loadedImage);
    NSData *storeData = firstPhotoOfUser.imageData;
    if (![originData isEqualToData:storeData]){
       STFail(@"Not match original image");
    }
    // check Thumbnail Photo
    NSData *originThumbnailData = UIImagePNGRepresentation([UIImage imageWithImage:loadedImage scaledToSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)]);
    NSData *storeThumbnailData = UIImagePNGRepresentation(firstPhotoOfUser.thumbnailPhoto);
    if (![originThumbnailData isEqualToData:storeThumbnailData]){
        STFail(@"Not match original thumbnail image");
    }
    
}

@end
