//
//  FEPlaceListTVC.m
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListTVC.h"
#import "FEPlaceListCell.h"
#import "FECoreDataController.h"
#import "CoredataCommon.h"
#import "Place.h"
#import "Address.h"
#import "AbstractInfo+Extension.h"
#import "Common.h"

@interface FEPlaceListTVC ()
@property (weak, nonatomic) FECoreDataController * coreData;
@property (strong, nonatomic) NSArray *places; // array of Places
@end

@implementation FEPlaceListTVC
- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
- (void)setPlaceSetting:(FESearchPlaceSettingInfo *)placeSetting {
    _placeSetting = placeSetting;
    [self queryDatabase];
}
#pragma mark - Core data
- (void)queryDatabase {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.coreData.managedObjectContext];
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    
    // TODO: speed up by query by Tag
//    https://developer.apple.com/library/mac/#documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetchExpressions.html
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
    request.entity = entity;
    NSError *error = nil;
    NSArray *results = [self.coreData.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
    self.places = results;
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaceListCell";
    FEPlaceListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FEPlaceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self updateCell:cell withPlaceInfo:self.places[indexPath.row]];
    return cell;
}

- (void)updateCell:(FEPlaceListCell*)cell withPlaceInfo:(Place*)place {
    cell.nameLbl.text = place.name;
    cell.addressLbl.text = place.address.address;
    cell.tagLbl.text = [place buildTagsString];
    cell.ratingView.rate = [place.rating integerValue];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
}

@end
