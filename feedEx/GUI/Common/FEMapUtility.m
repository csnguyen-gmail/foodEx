//
//  FEMapUtility.m
//  feedEx
//
//  Created by csnguyen on 8/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEMapUtility.h"

@interface FEMapUtility()<NSURLConnectionDelegate>
@end
#define GOOGLE_DIRECTION_URL @"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=driving&sensor=false"
@implementation FEMapUtility
+ (void)getDirectionFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
                   queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *locations))handle {
    NSString *fromStr = [NSString stringWithFormat:@"%f,%f",from.latitude, from.longitude];
    NSString *toStr = [NSString stringWithFormat:@"%f,%f",to.latitude, to.longitude];
    NSString *urlStr = [NSString stringWithFormat:GOOGLE_DIRECTION_URL, fromStr, toStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                                                      error:nil];
                               NSArray *routes = json[@"routes"];
                               NSArray *legs = routes[0][@"legs"];
                               NSArray *steps = legs[0][@"steps"];
                               NSMutableArray *locations = [NSMutableArray array];
                               for (NSDictionary *step in steps) {
                                   NSDictionary *startLocation = step[@"start_location"];
                                   double lat = [startLocation[@"lat"] doubleValue];
                                   double lng = [startLocation[@"lng"] doubleValue];
                                   CLLocationCoordinate2D location = {lat, lng};
                                   [locations addObject:[NSValue valueWithBytes:&location objCType:@encode(CLLocationCoordinate2D)]];
                               }
                               [locations addObject:[NSValue valueWithBytes:&to objCType:@encode(CLLocationCoordinate2D)]];
                               handle(locations);
                           }];
}

#define GOOGLE_DISTANCE_URL @"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%@&destinations=%@&mode=driving&sensor=false"
+ (void)getDistanceFrom:(CLLocationCoordinate2D)from to:(NSArray*)destPoints // list of CLLocationCoordinate2D
                  queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *distances))handle {
    if (destPoints.count == 0) {
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
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves
                                                                                      error:nil];
                               NSArray *rows = json[@"rows"];
                               NSArray *elements = rows[0][@"elements"];
                               NSMutableArray *distances = [NSMutableArray array];
                               for (NSDictionary *element in elements) {
                                   NSDictionary *distance = element[@"distance"];
                                   NSDictionary *duration = element[@"duration"];
                                   NSDictionary *info = @{@"distance":distance[@"text"], @"duration":duration[@"text"]};
                                   [distances addObject:info];
                               }
                               handle(distances);
                           }];
}

@end
