//
//  Photo.h
//  feedEx
//
//  Created by csnguyen on 2/7/14.
//  Copyright (c) 2014 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractInfo, OriginPhoto, ThumbnailPhoto;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) OriginPhoto *originPhoto;
@property (nonatomic, retain) AbstractInfo *owner;
@property (nonatomic, retain) ThumbnailPhoto *thumbnailPhoto;

@end
