//
//  FEMapUtility.h
//  feedEx
//
//  Created by csnguyen on 8/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FEDistanseInfo : NSObject
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *duration;
@end

@interface FEMapUtility : NSObject
@property (nonatomic, strong) CLLocation *location;
+ (FEMapUtility *)sharedInstance;
- (void)getDistanceToDestination:(CLLocationCoordinate2D)destCord queue:(NSOperationQueue *)queue completionHandler:(void (^)(FEDistanseInfo *info))handle;
- (void)getDirectionFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
                   queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *locations/* arrray of CLLocationCoordinate2D*/))handle;
- (void)getDistanceFrom:(CLLocationCoordinate2D)from to:(NSArray*)destPoints // list of CLLocationCoordinate2D
                  queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *distances)/* dictionary @{@"distance":value, @"duration":value}*/)handle;

@end
