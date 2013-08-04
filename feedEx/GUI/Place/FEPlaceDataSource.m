//
//  FEPlaceDataSource.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceDataSource.h"
#import "FECoreDataController.h"
#import "CoredataCommon.h"
#import "Common.h"


@interface FEPlaceDataSource()<CLLocationManagerDelegate>
@property (weak, nonatomic) FECoreDataController *coreData;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) LocationUpdateCompletionBlock locationUpdateCompletionBlock;
@end

@implementation FEPlaceDataSource
- (void)queryPlaceInfoWithSetting:(FESearchPlaceSettingInfo *)placeSetting{
    self.placeSetting = placeSetting;
    [self queryDatabase];
}
- (void)updateLocation:(LocationUpdateCompletionBlock)completion {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
    self.locationUpdateCompletionBlock = completion;
}

#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

#pragma mark - Core data
- (void)queryDatabase {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.coreData.managedObjectContext];;
    
    // filtering
    if (self.placeSetting.name.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.placeSetting.name];
        [predicates addObject:predicate];
    }
    if (self.placeSetting.address.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address.address CONTAINS[cd] %@", self.placeSetting.address];
        [predicates addObject:predicate];
    }
    if (self.placeSetting.rating != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rating == %@", @(self.placeSetting.rating)];
        [predicates addObject:predicate];
    }
    if (self.placeSetting.tags.length > 0) {
        NSArray *tagsString = [self.placeSetting.tags componentsSeparatedByString:SEPARATED_TAG_STR];
        NSMutableArray *tagPredicates = [[NSMutableArray alloc] init];
        for (NSString *tag in tagsString) {
            NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:@"tags.label CONTAINS[cd] %@", tag];
            [tagPredicates addObject:tagPredicate];
        }
        [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:tagPredicates]];
    }
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    // TODO: speed up by query by Tag
    // https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetchExpressions.html
    
    // sorting
    NSMutableArray *sorts = [[NSMutableArray alloc] init];
    if (self.placeSetting.firstSort.length > 0) {
        NSArray *sortsString = [self.placeSetting.firstSort componentsSeparatedByString:SEPARATED_SORT_STR];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:PLACE_SORT_TYPE_STRING_DICT[sortsString[0]]
                                                             ascending:[DIRECTION_STRING_LIST[0] isEqual:sortsString[1]]
                                                              selector:nil];
        [sorts addObject:sort];
    }
    if (self.placeSetting.secondSort.length > 0) {
        NSArray *sortsString = [self.placeSetting.secondSort componentsSeparatedByString:SEPARATED_SORT_STR];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:PLACE_SORT_TYPE_STRING_DICT[sortsString[0]]
                                                             ascending:[DIRECTION_STRING_LIST[0] isEqual:sortsString[1]]
                                                              selector:nil];
        [sorts addObject:sort];
    }
    request.sortDescriptors = sorts;
    
    
    NSError *error = nil;
    NSArray *results = [self.coreData.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
    self.places = results;
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    self.locationUpdateCompletionBlock(newLocation);
    [manager stopUpdatingLocation];
}
@end
