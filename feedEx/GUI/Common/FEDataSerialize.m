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

@implementation FEDataSerialize
/////////////////////
// Data structure
// +user: USER
// +places: Array of PLACE
/////////////////////
+ (NSData *)serializePlaces:(NSArray *)places ofUser:(User *)user {
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
@end
