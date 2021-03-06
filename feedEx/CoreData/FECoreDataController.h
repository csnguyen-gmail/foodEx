//
//  FECoreDataController.h
//  feedEx
//
//  Created by csnguyen on 4/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FECoreDataController : NSObject
// MOC that write to Persistence Store Coordinate on private thread
@property (readonly, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;
// MOC that Insert, Update, Delete model object on main thread
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSURL *storeURL;

// get instance
+ (FECoreDataController *)sharedInstance;
// save to disk disk asynchronously
- (void)saveToPersistenceStoreAndThenRunOnQueue:(NSOperationQueue*)queue withFinishBlock:(void(^)(NSError *error))block;
// save to disk disk synchronously
- (NSError*)saveToPersistenceStoreAndWait;

@end
