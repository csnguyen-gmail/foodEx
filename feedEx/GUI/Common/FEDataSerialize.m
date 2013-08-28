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
#import "Tag.h"

@implementation FEDataSerialize
/////////////////////
// Data structure
// +user: USER
// +places: Array of PLACE
/////////////////////
+ (NSData *)serializePlaces:(NSDictionary *)placeInfo {
    User *user = placeInfo[USER_KEY];
    NSArray *places = placeInfo[PLACES_KEY];
    NSMutableDictionary *rootDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    // User
    NSDictionary *userDict = [user toDictionaryBlockingRelationships:^BOOL(id obj, NSString *relationship) {
        BOOL preventRelationship=NO;
        // Manual prevent reverse relationship
        if ([obj isKindOfClass:NSClassFromString(@"Tag")]){
            if([relationship isEqualToString:@"owner"])
                preventRelationship=YES;
        }
        else if ([obj isKindOfClass:NSClassFromString(@"Photo")]){
            if([relationship isEqualToString:@"owner"])
                preventRelationship=YES;
        }
        return preventRelationship;
    } blockingEncode:^id(id obj) {
        if ([obj isKindOfClass:[UIImage class]]) {
            return UIImagePNGRepresentation(obj);
        }
        return obj;
    }];
    if (userDict != nil) {
        rootDict[USER_KEY] = userDict;
    }
    
    // Places
    NSMutableArray *arrayOfPlaceDict = [[NSMutableArray alloc] initWithCapacity:places.count];
    for (Place *place in places) {
        NSDictionary *placeDict = [place toDictionaryBlockingRelationships:^BOOL(id obj, NSString *relationship) {
            BOOL preventRelationship=NO;
            // Manual prevent reverse relationship
            if ([obj isKindOfClass:NSClassFromString(@"Tag")]){
                if([relationship isEqualToString:@"owner"])
                    preventRelationship=YES;
            }
            else if ([obj isKindOfClass:NSClassFromString(@"Photo")]){
                if([relationship isEqualToString:@"owner"])
                    preventRelationship=YES;
            }
            else if ([obj isKindOfClass:NSClassFromString(@"Food")]){
                if([relationship isEqualToString:@"placeOwner"])
                    preventRelationship=YES;
            }
            else if ([obj isKindOfClass:NSClassFromString(@"Address")]){
                if([relationship isEqualToString:@"placeOwner"])
                    preventRelationship=YES;
            }
            return preventRelationship;
        } blockingEncode:^id(id obj) {
            if ([obj isKindOfClass:[UIImage class]]) {
                return UIImagePNGRepresentation(obj);
            }
            return obj;
        }];
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
+(NSDictionary *)deserializePlaces:(NSData *)data {
    FECoreDataController *coreData = [FECoreDataController sharedInstance];
    BlockingValidation blockValidation = ^NSManagedObject *(NSManagedObject *managedObject)
    {
        if ([managedObject isKindOfClass:NSClassFromString(@"Tag")]) {
            Tag *tag = (Tag*)managedObject;
            NSFetchRequest *fetchRequest = [coreData.managedObjectModel fetchRequestFromTemplateWithName:FR_GetTagByType
                                                                                    substitutionVariables:@{FR_GetTagByType_Type:tag.type}];
            NSArray *tags = [coreData.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            for (Tag *tempTag in tags) {
                if (![tempTag.objectID isEqual:tag.objectID]) {
                    if ([tempTag.label isEqual:tag.label]) {
                        [coreData.managedObjectContext deleteObject:tag];
                        return tempTag;
                    }
                }
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
        [places insertObject:place atIndex:0];
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
