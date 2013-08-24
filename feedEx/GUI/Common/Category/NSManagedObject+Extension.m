//
//  NSManagedObject+Extension.m
//  feedEx
//
//  Created by csnguyen on 8/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "NSManagedObject+Extension.h"

@implementation NSManagedObject (Extension)
- (NSDictionary *)toDictionaryBlockingRelationships:(BlockingRelationship)blockRelationship
                                    blockingEncode:(BlockingEncode)blockEncode
{
	
    
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];
    
    [dict setObject:[[self class] description] forKey:@"class"];
    
    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        if (value != nil) {
            [dict setObject:blockEncode(value) forKey:attr];
        }
    }
    
    for (NSString* relationship in relationships) {
        if(!blockRelationship(self,relationship)){
            NSObject* value = [self valueForKey:relationship];
            
            if ([value isKindOfClass:[NSSet class]] || [value isKindOfClass:[NSOrderedSet class]]) {
                // To-many relationship
                
                // The core data set holds a collection of managed objects
                NSSet* relatedObjects = (NSSet*) value;
                
                // Our mutalble set holds a collection of dictionaries
                NSMutableOrderedSet* dictSet = [[NSMutableOrderedSet alloc] initWithCapacity:[relatedObjects count]];
                for (NSManagedObject *relatedObject in relatedObjects) {
                    NSDictionary *returnedDict=[relatedObject toDictionaryBlockingRelationships:blockRelationship blockingEncode:blockEncode];
                    if(returnedDict) {
                        [dictSet addObject:returnedDict];
                    }
                }
                
                if(dictSet) {
                    [dict setObject:dictSet forKey:relationship];
                }
            }
            else if ([value isKindOfClass:[NSManagedObject class]]) {
                // To-one relationship
                NSDictionary *returnedDict=nil;
                NSManagedObject* relatedObject = (NSManagedObject*) value;
				
                returnedDict=[relatedObject toDictionaryBlockingRelationships:blockRelationship blockingEncode:blockEncode];
                
                if (returnedDict)
                    [dict setObject:returnedDict forKey:relationship];
                
            }
        }
    }
    
    return dict;
}
+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context
                                    blockingValidation:(BlockingValidation)blockValidation
                                        blockingDecode:(BlockingDecode)blockDecode
{
    NSString* class = [dict objectForKey:@"class"];
    NSManagedObject* newObject =
	(NSManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:class
                                                    inManagedObjectContext:context];
	
    for (NSString* key in [dict allKeys]) {
        if ([key isEqualToString:@"class"]) {
            continue;
        }
		
        NSObject* value = [dict objectForKey:key];
		
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject* relatedObject =
			[NSManagedObject createManagedObjectFromDictionary:(NSDictionary*)value inContext:context
                                            blockingValidation:blockValidation blockingDecode:blockDecode];
			
            [newObject setValue:relatedObject forKey:key];
        }
        else if ([value isKindOfClass:[NSOrderedSet class]]) {
            // This is a to-many relationship
            NSOrderedSet* relatedObjectDictionaries = (NSOrderedSet*) value;
			
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            id relatedObjects;
            // Use try-catch to separate NSSet, NSOrderedSet --> this is BAD
            @try {
                relatedObjects = [newObject mutableSetValueForKey:key];
            }
            @catch (NSException *exception) {
                relatedObjects = [newObject mutableOrderedSetValueForKey:key];
            }
			
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* relatedObject =
				[NSManagedObject createManagedObjectFromDictionary:relatedObjectDict inContext:context
                                                blockingValidation:blockValidation blockingDecode:blockDecode];
                if (relatedObject) {
                    [relatedObjects addObject:relatedObject];
                }
            }
        }
        else if (value != nil) {
            // This is an attribute
            [newObject setValue:blockDecode(key, value) forKey:key];
        }
    }
	
    return blockValidation(newObject);
}
@end
