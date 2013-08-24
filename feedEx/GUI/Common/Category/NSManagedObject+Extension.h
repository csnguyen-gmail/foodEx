//
//  NSManagedObject+Extension.h
//  feedEx
//
//  Created by csnguyen on 8/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <CoreData/CoreData.h>
typedef BOOL (^BlockingRelationship)(id obj,NSString *relationship);
typedef id (^BlockingEncode)(id obj);
typedef id (^BlockingDecode)(NSString *key, id value);
typedef NSManagedObject* (^BlockingValidation)(NSManagedObject* managedObject);

@interface NSManagedObject (Extension)
- (NSDictionary*) toDictionaryBlockingRelationships:(BlockingRelationship)blockRelationship     // use in case need to prevent recursive relationship
                                     blockingEncode:(BlockingEncode)blockEncode;                // use for specific encode for some key    

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context
                                    blockingValidation:(BlockingValidation)blockValidation      // use in case need replace new NSManagedObject
                                        blockingDecode:(BlockingDecode)blockDecode;             // use for specific decode for some key
@end
