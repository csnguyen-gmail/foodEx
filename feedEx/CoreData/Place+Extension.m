//
//  Place+Extension.m
//  feedEx
//
//  Created by csnguyen on 5/5/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place+Extension.h"
#import "Address.h"

@implementation Place (Extension)
- (void)setAddressStringFromAddress:(Address*) address {
    self.addressString = [NSString stringWithFormat:@"%@ %@ %@ %@", address.address, address.district, address.city, address.country];
    self.address = address;
}
@end
