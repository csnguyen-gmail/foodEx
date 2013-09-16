//
//  ThumbnailPhoto.h
//  feedEx
//
//  Created by csnguyen on 9/16/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface ThumbnailPhoto : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) Photo *owner;

@end
