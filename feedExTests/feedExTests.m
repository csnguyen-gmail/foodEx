//
//  feedExTests.m
//  feedExTests
//
//  Created by csnguyen on 4/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "feedExTests.h"
#import "FECoreDataController.h"
#import "User+Additional.h"

@implementation feedExTests{
    FECoreDataController *_coredata;
}

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    _coredata = [[FECoreDataController alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - CoreData test;
- (void)testLoadUser
{
    // remove core data first
    [[NSFileManager defaultManager] removeItemAtURL:_coredata.storeURL  error:nil];
    User* user;
    // in case core data empty
    user = [User getUserInManagedObjectContext:_coredata.managedObjectContext];
    STAssertNotNil(user, @"Can not created User");
    // in case core data not empty
    user = [User getUserInManagedObjectContext:_coredata.managedObjectContext];
    STAssertNotNil(user, @"Can not created User");
    user = [User getUserInManagedObjectContext:_coredata.managedObjectContext];
    STAssertNotNil(user, @"Can not created User");
}

@end
