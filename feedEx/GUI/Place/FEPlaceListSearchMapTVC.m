//
//  FEPlaceListSearchMapTVC.m
//  feedEx
//
//  Created by csnguyen on 8/11/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListSearchMapTVC.h"
#import "FEPlaceListSearchMapCell.h"
#import "Address.h"
#import "Tag.h"
#import <CoreLocation/CoreLocation.h>
// TODO using batch size
@interface FEPlaceListSearchMapTVC ()<FEPlaceListSearchMapCellDelegate>
@end


@implementation FEPlaceListSearchMapTVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
}
#pragma mark - getter setter
- (void)setPlaces:(NSArray *)places {
    _places = places;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaceListSearchMapCell";
    FEPlaceListSearchMapCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath.row];
    return cell;
}
- (void)updateCell:(FEPlaceListSearchMapCell*)cell atIndexPath:(NSUInteger)index{
    Place *place = self.places[index];
    cell.delegate = self;
    cell.nameLbl.text = place.name;
    cell.addressLbl.text = place.address.address;
    cell.distanceLbl.text = place.distanceInfo;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 89;
//}
#pragma mark - FEPlaceListSearchMapCellDelegate
- (void)didSelectPlaceDetailAtCell:(FEPlaceListSearchMapCell *)cell {
    NSUInteger row = [[self.tableView indexPathForCell:cell] row];
    [self.searchDelegate searchMapDidSelectPlace:self.places[row]];
}

@end
