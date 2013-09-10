//
//  FECheckinVC.m
//  feedEx
//
//  Created by csnguyen on 9/9/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place+Extension.h"
#import "Address.h"
#import "FECheckinVC.h"
#import "FEPlaceListCheckinCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FECoreDataController.h"
#import "Common.h"
@interface FECheckinVC()<UITableViewDataSource, UITableViewDelegate, FEPlaceListCheckinCellDelegate, FEFlipPhotosViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *placesTV;
@property (nonatomic, strong) NSArray *places; // array of Place
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (weak, nonatomic) FECoreDataController *coreData;
@end
#define NUMBER_LATEST_PLACE_CHECKED_IN 10
@implementation FECheckinVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.placesTV.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.placesTV.layer.cornerRadius = 10;
    // load data
    [self refetchData];
    // core data changed tracking register
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coredateChanged:)
                                                 name:CORE_DATA_UPDATED object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CORE_DATA_UPDATED object:nil];
}

- (void)refetchData {
    self.places = [Place latestCheckinPlace:NUMBER_LATEST_PLACE_CHECKED_IN withMOC:self.coreData.managedObjectContext];
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.places.count];
    for (int i = 0; i< self.places.count; i++) {
        [self.imageIndexes addObject:@(0)];
    }
    [self.placesTV reloadData];
}

#pragma mark - handler DataModel changed
- (void)coredateChanged:(NSNotification *)info {
    [self refetchData];
}
#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}

#pragma mark - common
- (void)updateCell:(FEPlaceListCheckinCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    Place *place = self.places[indexPath.row];
    cell.delegate = self;
    cell.nameLbl.text = place.name;
    cell.addressLbl.text = place.address.address;
//    cell.chekinInfoLbl.text = [NSString stringWithFormat:@"Latest checkin time %@ (%@ times)", place.lastTimeCheckin, place.timesCheckin];
    cell.flipPhotosView.rowIndex = indexPath.row;
    cell.flipPhotosView.delegate = self;
    cell.flipPhotosView.usingThumbnail = YES;
    [cell.flipPhotosView setDatasource:[place.photos array]
                     withSelectedIndex:[self.imageIndexes[indexPath.row] integerValue]];
}

#pragma mark - Table data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaceListCheckinCell";
    FEPlaceListCheckinCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath];
    return cell;
}
#pragma mark - FEFlipPhotosViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    self.imageIndexes[row] = @(index);
}

#pragma mark - FEPlaceListCheckinCellDelegate
- (void)didSelectPlaceDetailAtCell:(FEPlaceListCheckinCell*)cell {
    
}
@end
