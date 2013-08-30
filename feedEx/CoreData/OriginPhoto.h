//
//  OriginPhoto.h
//  feedEx
//
//  Created by csnguyen on 8/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface OriginPhoto : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) Photo *owner;

@end
