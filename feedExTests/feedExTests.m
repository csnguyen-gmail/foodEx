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
#import "AbstractInfo+Extension.h"
#import "CoredataCommon.h"
#import "Tag.h"
#import "Common.h"
#import "NSManagedObject+Extension.h"
#import "Tag+Extension.h"
#import "NSData+Extension.h"
#import "OriginPhoto.h"
#import "ThumbnailPhoto.h"

#define TEST_IMAGE @"heart_selected"

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
    [user insertPhotoWithThumbnail:nil andOriginImage:[UIImage imageNamed:TEST_IMAGE] atIndex:0];
    Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
    tag.label = @"UserTag1";
    tag.type = CD_TAG_USER;
    [tag addOwnerObject:user];
    Tag *tag2 = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
    tag2.label = @"UserTag2";
    tag2.type = CD_TAG_USER;
    [tag2 addOwnerObject:user];
    for (int i = 0; i < 10; i++) {
        Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = [NSString stringWithFormat:@"Place%d", i];
        place.owner = user;
        place.rating = @(i % 6);
        place.timesCheckin = @(i);
        place.note = @"hello";
        [place insertPhotoWithThumbnail:nil andOriginImage:[UIImage imageNamed:TEST_IMAGE] atIndex:0];
        Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.label = [NSString stringWithFormat:@"PlaceTag%i", i];
        tag.type = CD_TAG_PLACE;
        [tag addOwnerObject:place];
        for (int j = 0; j < 2; j++) {
            Food *food = [NSEntityDescription insertNewObjectForEntityForName:@"Food" inManagedObjectContext:context];
            food.name = [NSString stringWithFormat:@"Food%d_%d", i, j];
            food.isBest = @(j%2==0);
            food.owner = place;
            [food insertPhotoWithThumbnail:nil andOriginImage:[UIImage imageNamed:TEST_IMAGE] atIndex:0];
            Tag *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            tag.label = [NSString stringWithFormat:@"FoodTag%i%i", i, j];
            tag.type = CD_TAG_FOOD;
            [tag addOwnerObject:food];
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
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestTemplateForName:FR_GetUser];
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
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestFromTemplateWithName:FR_GetPlaceByUserName
                                                                            substitutionVariables:@{FR_GetPlaceByUserName_Name:@"UserA"}];
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
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestFromTemplateWithName:FR_GetPlaceByUserName
                                                                            substitutionVariables:@{FR_GetPlaceByUserName_Name:@"UserA"}];
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
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestTemplateForName:FR_GetUser];
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
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestTemplateForName:FR_GetUser];
    NSArray *users = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    User *user = users.lastObject;
    UIImage *loadedImage = [UIImage imageNamed:TEST_IMAGE];
    Photo *firstPhotoOfUser = [user.photos objectAtIndex:0];
    // check origin Photo
    NSData *originData = UIImagePNGRepresentation(loadedImage);
    NSData *storeData = firstPhotoOfUser.originPhoto.imageData;
    if (![originData isEqualToData:storeData]){
       STFail(@"Not match original image");
    }
    // check Thumbnail Photo
    NSData *originThumbnailData = UIImagePNGRepresentation([UIImage imageWithImage:loadedImage scaledToSize:CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)]);
    NSData *storeThumbnailData = UIImagePNGRepresentation(firstPhotoOfUser.thumbnailPhoto.image);
    if (![originThumbnailData isEqualToData:storeThumbnailData]){
        STFail(@"Not match original thumbnail image");
    }
}

- (void)testGetTagByType
{
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestFromTemplateWithName:FR_GetTagByType
                                                                            substitutionVariables:@{FR_GetTagByType_Type:CD_TAG_PLACE}];
    NSArray *tags = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (tags.count == 10) {
        for (Tag *tag in tags) {
            if ([tag.label rangeOfString:@"Place"].length == 0) {
                STFail(@"Tag name is not correct");
            }
            Place *owner = [tag.owner anyObject];
            if ([owner.name rangeOfString:@"Place"].length == 0) {
                STFail(@"Food Tag owener is not correct");
            }
        }
    }
    else {
        STFail(@"Number of Food Tags doesn't correct");
    }
}

- (void)testSeriallizeUserData
{
    NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestTemplateForName:FR_GetUser];
    NSArray *users = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (users.count == 1) {
        User *user = users.lastObject;
        
        NSDictionary *dict = [user toDictionaryBlockingRelationships:^BOOL(id obj, NSString *relationship) {
            BOOL preventRelationship=NO;
            // Manual prevent reverse relationship
            if([relationship isEqualToString:@"owner"]) {
                preventRelationship=YES;
            }
            return preventRelationship;
        } blockingEncode:^id(id obj) {
            if ([obj isKindOfClass:[UIImage class]]) {
                return UIImagePNGRepresentation(obj);
            }
            return obj;
        }];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
        NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]);
        data = [data gzipDeflate];
        NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]);
        data = [data gzipInflate];
        NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]);
        dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        User *decodeUser = (User*)[NSManagedObject createManagedObjectFromDictionary:dict inContext:_coredata.managedObjectContext
                                                                  blockingValidation:^NSManagedObject *(NSManagedObject *managedObject)
                                   {
                                       if ([managedObject isKindOfClass:NSClassFromString(@"Tag")]) {
                                           Tag *tag = (Tag*)managedObject;
                                           NSFetchRequest *fetchRequest = [_coredata.managedObjectModel fetchRequestFromTemplateWithName:FR_GetTagByType
                                                                                                                   substitutionVariables:@{FR_GetTagByType_Type:tag.type}];
                                           NSArray *tags = [_coredata.managedObjectContext executeFetchRequest:fetchRequest error:nil];
                                           for (Tag *tempTag in tags) {
                                               if (![tempTag.objectID isEqual:tag.objectID]) {
                                                   if ([tempTag.label isEqual:tag.label]) {
                                                       [_coredata.managedObjectContext deleteObject:tag];
                                                       return tempTag;
                                                   }
                                               }
                                           }
                                       }
                                       return managedObject;
                                   }
                                                                      blockingDecode:^id(NSString *key, id value)
                                   {
                                       // convert to UIImage for thumbnail
                                       if ([key isEqualToString:@"thumbnailPhoto"]) {
                                           value = [UIImage imageWithData:value scale:[[UIScreen mainScreen] scale]];
                                       }
                                       return value;
                                   }];
        
        
        
        if (![decodeUser.name isEqual:user.name]) {
            STFail(@"User assignment is wrong");
        }
        for (int i = 0; i < decodeUser.photos.count; i++) {
            Photo *decodePhoto = decodeUser.photos[i];
            Photo *photo = user.photos[i];
            if (![decodePhoto.originPhoto.imageData isEqualToData:photo.originPhoto.imageData]) {
                STFail(@"Blob data assignment is wrong");
            }
            NSData *decodeImage = UIImagePNGRepresentation(decodePhoto.thumbnailPhoto.image);
            NSData *image = UIImagePNGRepresentation(photo.thumbnailPhoto.image);
            if (![decodeImage isEqualToData:image]) {
                STFail(@"Image assignment is wrong");
            }
        }
        NSArray *decodeUserTags = [decodeUser.tags sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES]]];
        NSArray *userTags = [user.tags sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES]]];
        for (int i = 0; i < decodeUserTags.count; i++) {
            if ([decodeUserTags[i] objectID] != [userTags[i] objectID]) {
                STFail(@"Tag assignment is wrong");
            }
        }
        
        NSArray *decodeUserPlaces = [decodeUser.places sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
        NSArray *userPlaces = [user.places sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
        for (int i = 0; i < decodeUser.places.count; i++) {
            Place* decodePlace = decodeUserPlaces[i];
            Place* place = userPlaces[i];
            if (![decodePlace.name isEqual:place.name]) {
                STFail(@"Place assignment is wrong");
            }
            NSArray *decodePlaceFoods = [decodePlace.foods sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
            NSArray *placeFoods = [place.foods sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
            for (int j = 0; j < decodePlace.foods.count; j++) {
                Food *decodeFood = decodePlaceFoods[j];
                Food *food = placeFoods[j];
                if (![decodeFood.name isEqual:food.name]) {
                    STFail(@"Food assignment is wrong");
                }
            }
        }
        
    }
    else {
        STFail(@"Number of User doesn't correct");
    }
}

@end
