//
//  Photo.h
//  feedEx
//
//  Created by csnguyen on 5/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractInfo;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) AbstractInfo *owner;

@end
