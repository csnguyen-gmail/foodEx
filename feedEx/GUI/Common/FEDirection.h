//
//  FEDirection.h
//  feedEx
//
//  Created by csnguyen on 8/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface FEDirection : NSObject
+(void)getDirectionFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
                  queue:(NSOperationQueue*) queue completionHandler:(void (^)(NSArray *locations))handler;
@end
