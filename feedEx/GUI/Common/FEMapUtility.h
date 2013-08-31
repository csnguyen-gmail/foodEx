//
//  FEMapUtility.h
//  feedEx
//
//  Created by csnguyen on 8/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface FEMapUtility : NSObject
+ (void)getDirectionFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
                   queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *locations/* arrray of CLLocationCoordinate2D*/))handle;
+ (void)getDistanceFrom:(CLLocationCoordinate2D)from to:(NSArray*)destPoints // list of CLLocationCoordinate2D
                  queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *distances)/* dictionary @{@"distance":value, @"duration":value}*/)handle;
@end
