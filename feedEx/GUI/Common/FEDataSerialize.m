//
//  FEDataSerialize.m
//  feedEx
//
//  Created by csnguyen on 8/26/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEDataSerialize.h"
#import "NSManagedObject+Extension.h"
#import "Place.h"
#import "NSData+Extension.h"
#import "FECoreDataController.h"
#import "CoredataCommon.h"
#import "Tag+Extension.h"
#import "User+Extension.h"

@implementation FEDataSerialize
/////////////////////
// Data structure
// +user: USER
// +places: Array of PLACE
/////////////////////
+ (NSData *)serializeMailData:(NSDictionary *)placeInfo {
    // share blocks
    BlockingEncode blockEncode = ^id(id obj) {
        if ([obj isKindOfClass:[UIImage class]]) {
            return UIImagePNGRepresentation(obj);
        }
        return obj;
    };
    BlockingRelationship blockRelationship = ^BOOL(id obj,NSString *relationship) {
        BOOL preventRelationship=NO;
        // Manual prevent reverse relationship
        if([relationship isEqualToString:@"places"]) {
            preventRelationship=YES;
        }
        else if([relationship isEqualToString:@"owner"]) {
            preventRelationship=YES;
        }
        return preventRelationship;
    };
    
    User *user = placeInfo[USER_KEY];
    NSArray *places = placeInfo[PLACES_KEY];
    NSMutableDictionary *rootDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    // User
    NSMutableDictionary *userDict = [user toDictionaryBlockingRelationships:blockRelationship blockingEncode:blockEncode];
    if (userDict != nil) {
        userDict[@"tags"][0][@"label"] = USER_FRIEND_TAG;
        rootDict[USER_KEY] = userDict;
    }
    
    // Places
    NSMutableArray *arrayOfPlaceDict = [[NSMutableArray alloc] initWithCapacity:places.count];
    for (Place *place in places) {
        NSDictionary *placeDict = [place toDictionaryBlockingRelationships:blockRelationship blockingEncode:blockEncode];
        [arrayOfPlaceDict insertObject:placeDict atIndex:0];
    }
    if (arrayOfPlaceDict) {
        rootDict[PLACES_KEY] = arrayOfPlaceDict;   
    }
    
    // encode to NSData
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rootDict];
    // zip data
    data = [data gzipDeflate];
    
    return data;
}
+(NSDictionary *)deserializeMailData:(NSData *)data {
    // share blocks
    BlockingValidation blockValidation = ^NSManagedObject *(NSManagedObject *managedObject)
    {
        FECoreDataController *coreData = [FECoreDataController sharedInstance];
        if ([managedObject isKindOfClass:NSClassFromString(@"Tag")]) {
            // in case new Tag existed (decide by label) in Application, then ignore new Tag and return existed one
            Tag *newTag = (Tag*)managedObject;
            NSArray *results = [Tag fetchTagsByType:newTag.type andLabel:newTag.label];
            if (results.count > 1) {
                managedObject = ([results[0] objectID] == newTag.objectID) ? results[1] : results[0];
                [coreData.managedObjectContext deleteObject:newTag];
            }
        }
        else if ([managedObject isKindOfClass:NSClassFromString(@"User")]) {
            // in case new User existed (decide by email) in Application, then update by new User and remove existed one
            User *newUser = (User*)managedObject;
            NSArray *results = [User fetchUsersByEmail:newUser.email andUserType:[newUser.tags[0] label]];
            if (results.count > 1) {
                User* existedUser = results[0];
                for (Place *place in existedUser.places) {
                    place.owner = newUser;
                }
                [coreData.managedObjectContext deleteObject:existedUser];
            }
        }
        return managedObject;
    };
    BlockingDecode blockDecode = ^id(NSString *key, id value)
    {
        // convert to UIImage for thumbnail
        if ([key isEqualToString:@"thumbnailPhoto"]) {
            value = [UIImage imageWithData:value scale:[[UIScreen mainScreen] scale]];
        }
        return value;
    };
    // unzip data
    data = [data gzipInflate];
    // decode to NSDictionary
    NSDictionary *rootDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    FECoreDataController *coreData = [FECoreDataController sharedInstance];
    // User
    NSDictionary *userDict = rootDict[USER_KEY];
    User *user = (User*)[NSManagedObject createManagedObjectFromDictionary:userDict inContext:coreData.managedObjectContext
                                                        blockingValidation:blockValidation
                                                            blockingDecode:blockDecode];
    // Places
    NSArray *arrayOfPlaceDict = rootDict[PLACES_KEY];
    NSMutableArray *places = [NSMutableArray array];
    for (NSDictionary *placeDict in arrayOfPlaceDict) {
        Place *place = (Place*)[NSManagedObject createManagedObjectFromDictionary:placeDict inContext:coreData.managedObjectContext
                                                               blockingValidation:blockValidation
                                                                   blockingDecode:blockDecode];
        // re-create releation to owner
        place.owner = user;
        [places addObject:place];
    }
    if (places.count == 0) {
        return  nil;
    }
    // Save to disk
    NSError *error = [coreData saveToPersistenceStoreAndWait];
    if (error) {
        return nil;
    }
    NSMutableDictionary *placeInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    if (user) {
        placeInfo[USER_KEY] = user;
    }
    placeInfo[PLACES_KEY] = places;
    return placeInfo;
}
@end
