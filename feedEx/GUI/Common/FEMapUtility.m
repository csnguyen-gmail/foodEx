//
//  FEMapUtility.m
//  feedEx
//
//  Created by csnguyen on 8/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEMapUtility.h"
#import "Common.h"
#import <CoreData/CoreData.h>
@implementation FEDistanseInfo
@end

@interface FEMapUtility()<NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableDictionary *distanceInfo; // dictionary include ObjectID/FEDistanceInfo
@end

@implementation FEMapUtility
+ (FEMapUtility *)sharedInstance {
    static dispatch_once_t onceToken;
    static FEMapUtility *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[FEMapUtility alloc] init];
    });
    return shared;
}
- (NSMutableDictionary *)distanceInfo {
    if (_distanceInfo == nil) {
        _distanceInfo = [[NSMutableDictionary alloc] init];
    }
    return _distanceInfo;
}
#pragma mark - getter setter
- (void)setLocation:(CLLocation *)location {
    _location = location;
    [self.distanceInfo removeAllObjects];
}

#define GOOGLE_DIRECTION_URL @"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=driving&sensor=false"
- (void)getDirectionFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
                   queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *locations))handle {
    NSString *fromStr = [NSString stringWithFormat:@"%f,%f",from.latitude, from.longitude];
    NSString *toStr = [NSString stringWithFormat:@"%f,%f",to.latitude, to.longitude];
    NSString *urlStr = [NSString stringWithFormat:GOOGLE_DIRECTION_URL, fromStr, toStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (data == nil) {
                                   NSLog(@"get Direction failed: %@", error);
                                   handle(nil);
                                   return;
                               }
                               NSMutableArray *locations = [NSMutableArray array];
                               @try {
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                                                          error:nil];
                                   NSArray *routes = json[@"routes"];
                                   if (routes.count == 0) {
                                       handle(nil);
                                       return;
                                   }
                                   NSArray *legs = routes[0][@"legs"];
                                   NSArray *steps = legs[0][@"steps"];
                                   for (NSDictionary *step in steps) {
                                       NSDictionary *startLocation = step[@"start_location"];
                                       double lat = [startLocation[@"lat"] doubleValue];
                                       double lng = [startLocation[@"lng"] doubleValue];
                                       CLLocationCoordinate2D location = {lat, lng};
                                       [locations addObject:[NSValue valueWithBytes:&location objCType:@encode(CLLocationCoordinate2D)]];
                                   }
                                   [locations addObject:[NSValue valueWithBytes:&to objCType:@encode(CLLocationCoordinate2D)]];
                               }
                               @catch (NSException *exception) {
                                   NSLog(@"Get Direction failed.");
                                   [locations addObject:[NSValue valueWithBytes:&from objCType:@encode(CLLocationCoordinate2D)]];
                                   [locations addObject:[NSValue valueWithBytes:&to objCType:@encode(CLLocationCoordinate2D)]];
                                   
                               }
                               @finally {
                                   handle(locations);
                               }
                           }];
}

#define GOOGLE_DISTANCE_URL @"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=%@&mode=driving&sensor=false"
- (void)getDistanceFrom:(CLLocationCoordinate2D)from to:(NSArray*)destPoints // list of CLLocationCoordinate2D
                  queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *distances))handle {
    if (destPoints.count == 0) {
        [queue addOperationWithBlock:^{
            handle(nil);
        }];
        return;
    }
    NSString *fromStr = [NSString stringWithFormat:@"%f,%f",from.latitude, from.longitude];
    NSMutableString *toStrs = [NSMutableString string];
    for (int i = 0; i < destPoints.count; i++) {
        CLLocationCoordinate2D to;
        [[destPoints objectAtIndex:i] getValue:&to];
        if (i != 0) {
            [toStrs appendString:@"%7C"]; // represent '|'
        }
        [toStrs appendFormat:@"%f,%f",to.latitude, to.longitude];
    }
    NSString *urlStr = [NSString stringWithFormat:GOOGLE_DISTANCE_URL, fromStr, toStrs];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (data == nil) {
                                   NSLog(@"get Distanse failed: %@", error);
                                   handle(nil);
                                   return;
                               }
                               NSMutableArray *distances = [NSMutableArray array];
                               @try {
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                                                          error:nil];
                                   NSArray *rows = json[@"rows"];
                                   NSArray *elements = rows[0][@"elements"];
                                   for (NSDictionary *element in elements) {
                                       NSDictionary *distance = element[@"distance"];
                                       NSDictionary *duration = element[@"duration"];
                                       if (distance == nil || duration == nil) {
                                           continue;
                                       }
                                       NSDictionary *info = @{@"distance":distance[@"text"], @"duration":duration[@"text"]};
                                       [distances addObject:info];
                                   }
                               }
                               @catch (NSException *exception) {
                                   NSLog(@"Get Distance failed.");
                               }
                               @finally {
                                   handle(distances);
                               }
                           }];
}

- (void)getDistanceToDestination:(CLLocationCoordinate2D)destCord queue:(NSOperationQueue *)queue completionHandler:(void (^)(FEDistanseInfo *info))handle {
    NSString *key = [NSString stringWithFormat:@"%f, %f", destCord.latitude, destCord.longitude];
    FEDistanseInfo *info = self.distanceInfo[key];
    if (info == nil) {
        info = [[FEDistanseInfo alloc] init];
        self.distanceInfo[key] = info;
        
        NSValue *destValue = [NSValue valueWithBytes:&destCord objCType:@encode(CLLocationCoordinate2D)];
        [self getDistanceFrom:self.location.coordinate to:@[destValue] queue:queue completionHandler:^(NSArray *distances) {
            if (distances.count > 0) {
                NSDictionary *distanceInfo = distances[0];
                info.distance = distanceInfo[@"distance"];
                info.duration = distanceInfo[@"duration"];
                [queue addOperationWithBlock:^{
                    handle(info);
                }];
            }
            // reset in case get distance error
            else {
                [self.distanceInfo removeObjectForKey:key];
            }
        }];
        return;
    }
    if ((info.distance == nil) || (info.duration == nil)) {
        [queue addOperationWithBlock:^{
            [queue addOperationWithBlock:^{
                handle(info);
            }];
        }];
    }
}


@end
