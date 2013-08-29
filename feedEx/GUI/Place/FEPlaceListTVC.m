//
//  FEPlaceListTVC.m
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListTVC.h"
#import "FEPlaceListCell.h"
#import "Place.h"
#import "Address.h"
#import "AbstractInfo+Extension.h"
#import "Photo.h"
#import <QuartzCore/QuartzCore.h>
#import "FEPlaceDetailMainVC.h"
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
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeDetail"]) {
        FEPlaceDetailMainVC *placeDetailVC = [segue destinationViewController];
        placeDetailVC.place = self.placeDataSource.places[self.selectedRow];
    }
}
#pragma mark - getter setter
- (void)setPlaceDataSource:(FEPlaceDataSource *)placeDataSource {
    _placeDataSource = placeDataSource;
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.placeDataSource.places.count];
    for (int i = 0; i< self.placeDataSource.places.count; i++) {
        [self.imageIndexes addObject:@(0)];
    }
    [self.tableView reloadData];
}
- (UIView *)selectedBackgroundView {
    if (_selectedBackgroundView == nil) {
        _selectedBackgroundView = [[UIView alloc] init];
    }
    return _selectedBackgroundView;
}
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    self.tableView.editing = isEditMode;
    [self.tableView reloadData];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placeDataSource.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaceListCell";
    FEPlaceListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath.row];
    return cell;
}
#define TAG_PADDING 5.0
#define TAG_HORIZON_MARGIN 10.0
#define TAG_VERTICAL_MARGIN 5.0
- (void)updateCell:(FEPlaceListCell*)cell atIndexPath:(NSUInteger)index{
    cell.selectedBackgroundView = self.selectedBackgroundView;
    cell.informationBtn.enabled = !self.isEditMode;
    Place *place = self.placeDataSource.places[index];
    cell.delegate = self;
    cell.nameLbl.text = place.name;
    cell.addressLbl.text = place.address.address;
    cell.ratingView.rate = [place.rating integerValue];
    cell.flipPhotosView.rowIndex = index;
    cell.flipPhotosView.delegate = self;
    cell.flipPhotosView.usingThumbnail = YES;
    [cell.flipPhotosView setDatasource:[place.photos array]
                     withSelectedIndex:[self.imageIndexes[index] integerValue]];
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
    // TODO
    if (self.placeDataSource.currentLocation) {
        double placeLon = [place.address.longtitude doubleValue];
        double placeLat = [place.address.lattittude doubleValue];
        if (placeLon != 0.0 && placeLat != 0.0){
            CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:placeLat longitude:placeLon];
            CLLocationDistance distance = [placeLocation distanceFromLocation:self.placeDataSource.currentLocation];
            if (distance < 1000) {
                cell.distanceLbl.text = [NSString stringWithFormat:@"About %d meters from here.", (int)distance];
            } else {
                cell.distanceLbl.text = [NSString stringWithFormat:@"About %.2f kilometers from here.", distance / 1000];
            }
        } else {
            cell.distanceLbl.text = @"";
        }
    } else {
        cell.distanceLbl.text = @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 89;
}
#pragma mark - FEFlipPhotosViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    self.imageIndexes[row] = @(index);
}
#pragma mark - FEPlaceListCellDelegate
- (void)didSelectPlaceDetailAtCell:(FEPlaceListCell *)cell {
    self.selectedRow = [[self.tableView indexPathForCell:cell] row];
    [self performSegueWithIdentifier:@"placeDetail" sender:self];
}

@end
