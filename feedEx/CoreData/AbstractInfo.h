//
//  AbstractInfo.h
//  feedEx
//
//  Created by csnguyen on 5/3/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AbstractInfo : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * photoOriginUrl;
@property (nonatomic, retain) NSString * photoThumbnailUrl;

@end
