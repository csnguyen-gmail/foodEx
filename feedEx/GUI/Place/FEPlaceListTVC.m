//
//  FEPlaceListTVC.m
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListTVC.h"
#import "FEPlaceListCell.h"
#import "Place+Extension.h"
#import "Address.h"
#import "AbstractInfo+Extension.h"
#import "Photo.h"
#import <QuartzCore/QuartzCore.h>
#import "FEPlaceDetailMainVC.h"
#import "FEMapUtility.h"
#import "FEAppDelegate.h"
#import "FEPlaceEditMainVC.h"
// TODO using batch size
@interface FEPlaceListTVC ()<FEFlipPhotosViewDelegate, FEPlaceListCellDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (nonatomic) NSUInteger selectedRow;
@property (nonatomic, strong) UIView *selectedBackgroundView;
@end

@implementation FEPlaceListTVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.tableView.layer.cornerRadius = 10;
    [self.refreshControl addTarget:self action:@selector(refreshGUITriggered) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to update location."];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeDetail"]) {
        FEPlaceDetailMainVC *placeDetailVC = [segue destinationViewController];
        placeDetailVC.place = self.placesForDisplay[self.selectedRow];
    }
    else if ([[segue identifier] isEqualToString:@"placeDetailEdit"]) {
        UINavigationController *navigation = [segue destinationViewController];
        FEPlaceEditMainVC *editPlaceInfoMainVC = navigation.viewControllers[0];
        editPlaceInfoMainVC.placeInfo = self.placesForDisplay[self.selectedRow];
    }
}
- (NSArray *)getSelectedPlaces {
    NSMutableArray *selectedPlaces = [NSMutableArray array];
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *index in selectedRows) {
        [selectedPlaces addObject:self.placesForDisplay[index.row]];
    }    return selectedPlaces;

}
- (void)updatePlacesWithSettingInfo:(FESearchPlaceSettingInfo *)placeSetting {
    self.places = [Place placesFromPlaceSettingInfo:placeSetting];
    [self setQuickSearchString:nil withAnimated:NO];
}
- (void)setSelectAll:(BOOL)selectAll {
    for (int i = 0; i < [self.tableView numberOfSections]; i++) {
        for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
            NSUInteger ints[2] = {i,j};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
            if (selectAll) {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
    [self.placeListDelegate didSelectPlaceRow];
}
#pragma mark - getter setter
- (void)setQuickSearchString:(NSString *)quickSearchString withAnimated:(BOOL)animated{
    _quickSearchString = quickSearchString;
    // filtering
    if (quickSearchString.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", quickSearchString];
        self.placesForDisplay = [self.places filteredArrayUsingPredicate:predicate];
    }
    else {
        self.placesForDisplay = self.places;
    }
    // reset image indexes
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.placesForDisplay.count];
    for (int i = 0; i< self.placesForDisplay.count; i++) {
        [self.imageIndexes addObject:@(0)];
    }
    if (animated) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self.tableView reloadData];
    }
}

- (UIView *)selectedBackgroundView {
    if (_selectedBackgroundView == nil) {
        _selectedBackgroundView = [[UIView alloc] init];
    }
    return _selectedBackgroundView;
}
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    [self.tableView setEditing:isEditMode animated:YES];
    [self.tableView reloadData];
}
- (void)setCurrentLocation:(CLLocation *)currentLocation {
    _currentLocation = currentLocation;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}
- (void) refreshGUITriggered {
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate updateLocation];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableView.isEditing) {
        return self.placesForDisplay.count;
    }
    return self.placesForDisplay.count + 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.placesForDisplay.count) {
        return 89;
    }
    return 22;
}
#define kSummaryInfoLblTag 100
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaceListCell";
    static NSString *LastCellIdentifier = @"PlaceListLastCell";
    if (indexPath.row == self.placesForDisplay.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellIdentifier forIndexPath:indexPath];
        UILabel *sumInfoLbl = (UILabel*)[cell viewWithTag:kSummaryInfoLblTag];
        sumInfoLbl.text = [[NSString alloc] initWithFormat:@"Total %d places", self.placesForDisplay.count];
        return cell;
    }
    FEPlaceListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath];
    return cell;
}
#define TAG_PADDING 5.0
#define TAG_HORIZON_MARGIN 10.0
#define TAG_VERTICAL_MARGIN 5.0
- (void)updateCell:(FEPlaceListCell*)cell atIndexPath:(NSIndexPath*)index{
    cell.selectedBackgroundView = self.selectedBackgroundView;
    cell.isEditMode = self.isEditMode;
    Place *place = self.placesForDisplay[index.row];
    cell.delegate = self;
    cell.nameLbl.text = place.name;
    cell.addressLbl.text = place.address.address;
    cell.ratingView.rate = [place.rating integerValue];
    cell.chekinTimesLbl.text = [place.timesCheckin description];;
    cell.flipPhotosView.rowIndex = index.row;
    cell.flipPhotosView.delegate = self;
    cell.flipPhotosView.usingThumbnail = YES;
    [cell.flipPhotosView setDatasource:[place.photos array]
                     withSelectedIndex:[self.imageIndexes[index.row] integerValue]];
    [cell.tagsScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (place.tags.count > 0) {
        CGFloat contentWidth = 0.0;
        for (Tag *tag in place.tags) {
            UIFont *font = [UIFont systemFontOfSize:10];
            CGSize tagSize = [tag.label sizeWithFont:font];
            tagSize.width += TAG_HORIZON_MARGIN;
            tagSize.height += TAG_VERTICAL_MARGIN;
            UILabel *tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth, 0, tagSize.width, tagSize.height)];
            tagLbl.adjustsFontSizeToFitWidth = YES;
            tagLbl.minimumScaleFactor = 0.1;
            tagLbl.textAlignment = NSTextAlignmentCenter;
            tagLbl.text = tag.label;
            tagLbl.font = font;
            tagLbl.textColor = [UIColor whiteColor];
            tagLbl.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1];
            tagLbl.layer.cornerRadius = 5;
            tagLbl.layer.borderColor = [[UIColor whiteColor] CGColor];
            tagLbl.layer.borderWidth = 0.8;
            [cell.tagsScrollView addSubview:tagLbl];
            contentWidth += tagSize.width + TAG_PADDING;
        }
        CGSize size = cell.tagsScrollView.contentSize;
        size.width = contentWidth;
        cell.tagsScrollView.contentSize = size;
    }
    cell.distanceLbl.text = @"";
    
    CLLocationCoordinate2D placeLoc = CLLocationCoordinate2DMake([place.address.lattittude doubleValue], [place.address.longtitude doubleValue]);
    [[FEMapUtility sharedInstance] getDistanceToDestination:placeLoc queue:[NSOperationQueue mainQueue] completionHandler:^(FEDistanseInfo *info) {
        FEPlaceListCell *cell = (FEPlaceListCell*)[self.tableView cellForRowAtIndexPath:index];
        // fix bug cell is not generate correctly in case type quick search quickly
        if ([cell class] == [FEPlaceListCell class]) {
            cell.distanceLbl.text = [NSString stringWithFormat:@"About %@ from here, estimate %@ driving.", info.distance, info.duration];
        }
    }];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing == YES) {
        [self.placeListDelegate didSelectPlaceRow];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing == YES) {
        [self.placeListDelegate didSelectPlaceRow];
    }
}
// hide empty row
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
#pragma mark - FEFlipPhotosViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    self.imageIndexes[row] = @(index);
}
#pragma mark - FEPlaceListCellDelegate
- (void)didSelectPlaceDetailAtCell:(FEPlaceListCell *)cell {
    self.selectedRow = [[self.tableView indexPathForCell:cell] row];
    if (self.isEditMode) {
        [self performSegueWithIdentifier:@"placeDetailEdit" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"placeDetail" sender:self];
    }
}

@end
