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

@interface FEPlaceListTVC ()<FEFlipPhotosViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@end

@implementation FEPlaceListTVC
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaceListCell";
    FEPlaceListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FEPlaceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self updateCell:cell withPlaceInfo:self.places[indexPath.row] atIndexPath:indexPath];
    return cell;
}
#define TAG_PADDING 5.0
#define TAG_HORIZON_MARGIN 10.0
#define TAG_VERTICAL_MARGIN 5.0
- (void)updateCell:(FEPlaceListCell*)cell withPlaceInfo:(Place*)place atIndexPath:(NSIndexPath*)indexPath{
    cell.nameLbl.text = place.name;
    cell.addressLbl.text = place.address.address;
    cell.ratingView.rate = [place.rating integerValue];
    cell.flipPhotosView.rowIndex = indexPath.row;
    cell.flipPhotosView.delegate = self;
    cell.flipPhotosView.usingThumbnail = YES;
    [cell.flipPhotosView setDatasource:[place.photos array]
                     withSelectedIndex:[self.imageIndexes[indexPath.row] integerValue]];
    [cell.tagsScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (place.tags.count > 0) {
        CGFloat contentWidth = 0.0;
        for (Tag *tag in place.tags) {
            UIFont *font = [UIFont systemFontOfSize:10];
            CGSize tagSize = [tag.label sizeWithFont:font];
            tagSize.width += TAG_HORIZON_MARGIN;
            tagSize.height += TAG_VERTICAL_MARGIN;
            UILabel *tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth, 0, tagSize.width, tagSize.height)];
            tagLbl.textAlignment = NSTextAlignmentCenter;
            tagLbl.text = tag.label;
            tagLbl.font = font;
            tagLbl.textColor = [UIColor whiteColor];
            tagLbl.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.2];
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
    if (self.currentLocation) {
        double placeLon = [place.address.longtitude doubleValue];
        double placeLat = [place.address.lattittude doubleValue];
        if (placeLon != 0.0 && placeLat != 0.0){
            CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:placeLat longitude:placeLon];
            CLLocationDistance distance = [placeLocation distanceFromLocation:self.currentLocation];
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
    return 90;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
}
#pragma mark - FEFlipPhotosViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    self.imageIndexes[row] = @(index);
}

#pragma mark - implement abstract functions
- (void)didChangeDataSource {
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.places.count];
    for (int i = 0; i< self.places.count; i++) {
        [self.imageIndexes addObject:@(0)];
    }
}

@end
