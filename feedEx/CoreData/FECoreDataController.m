//
//  FECoreDataController.m
//  feedEx
//
//  Created by csnguyen on 4/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FECoreDataController.h"
#ifdef TEST
#define DATA_BASE_NAME @"feedex_test.sqlite"
#else
#define DATA_BASE_NAME @"feedex.sqlite"
#endif

@implementation FECoreDataController
@synthesize writerManagedObjectContext = _writerManagedObjectContext;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize storeURL = _storeURL;

+ (FECoreDataController *)sharedInstance {
    static dispatch_once_t onceToken;
    static FECoreDataController *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[FECoreDataController alloc] init];
    });
    return shared;
}
#pragma mark - Core Data stack
// Return store URL
- (NSURL *)storeURL{
    if (_storeURL != nil) {
        return _storeURL;
    }
    
    _storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    _storeURL = [_storeURL URLByAppendingPathComponent:DATA_BASE_NAME];
    
    return _storeURL;
}
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)writerManagedObjectContext
{
    if (_writerManagedObjectContext != nil) {
        return _writerManagedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_writerManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _writerManagedObjectContext;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and act as child context of writerContext.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSManagedObjectContext *writerContext = self.writerManagedObjectContext;
    if (writerContext != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = writerContext;
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"feedex" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSError *error = nil;
//    // preloading from database in pre-created in Bundle
//    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.storeURL path]]) {
//        NSString *preloadPath = [[NSBundle mainBundle] pathForResource:@"feedExDatabaseGenerate" ofType:@"sqlite"];
//        if (preloadPath) {
//            NSURL *preloadURL = [NSURL fileURLWithPath:preloadPath];
//            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:self.storeURL error:&error]) {
//                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            }
//        }
//    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL
                                                         options:@{NSMigratePersistentStoresAutomaticallyOption:@YES}
                                                           error:&error]) {        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Utility functions
- (void)saveToPersistenceStoreAndThenRunOnQueue:(NSOperationQueue *)queue withFinishBlock:(void (^)(NSError *))block {
    NSManagedObjectContext *mainContext = self.managedObjectContext;
    NSManagedObjectContext *writerContext = self.writerManagedObjectContext;
    [mainContext performBlock:^{
        // push modification to writer context (Main thread)
        NSError *mainError;
        if ([mainContext save:&mainError]) {
            [writerContext performBlock:^{
                // push modification to disk (Private thread)
                NSError *writerError;
                if ([writerContext hasChanges]) {
                    [writerContext save:&writerError];
                }
                [queue addOperationWithBlock:^{
                    block(writerError);
                }];
            }];
        }
        else {
            [queue addOperationWithBlock:^{
                block(mainError);
            }];
        }
    }];
}
- (NSError *)saveToPersistenceStoreAndWait {
    NSManagedObjectContext *mainContext = self.managedObjectContext;
    NSManagedObjectContext *writerContext = self.writerManagedObjectContext;
    __block NSError *error;
    [mainContext performBlockAndWait:^{
        // push modification to writer context (Main thread)
        if ([mainContext save:&error]) {
            [writerContext performBlockAndWait:^{
                if ([writerContext hasChanges]) {
                    // push modification to disk (Private thread)
                    [writerContext save:&error];
                }
            }];
        }
    }];
    return error;
}
@end
