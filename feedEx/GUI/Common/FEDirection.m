//
//  FEDirection.m
//  feedEx
//
//  Created by csnguyen on 8/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEDirection.h"

@interface FEDirection()<NSURLConnectionDelegate>
@end
#define GOOGLE_DIRECTION_URL @"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=driving&sensor=false"
@implementation FEDirection
+ (void)getDirectionFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSArray *))handle {
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
@end
