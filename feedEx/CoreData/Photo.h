//
//  Photo.h
//  feedEx
//
//  Created by csnguyen on 8/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractInfo, OriginPhoto;

@interface Photo : NSManagedObject

@property (nonatomic, retain) id thumbnailPhoto;
@property (nonatomic, retain) AbstractInfo *owner;
@property (nonatomic, retain) OriginPhoto *originPhoto;

@end
