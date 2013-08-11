//
//  FEPlaceListSearchMapTVC.m
//  feedEx
//
//  Created by csnguyen on 8/11/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListSearchMapTVC.h"
#import "FEPlaceListCell.h"
#import "Address.h"
#import "Tag.h"
#import <CoreLocation/CoreLocation.h>
// TODO using batch size
@interface FEPlaceListSearchMapTVC ()<FEFlipPhotosViewDelegate, FEPlaceListCellDelegate>
@property (nonatomic, strong) NSMutableDictionary *imageIdDict; // pair of ObjectID and NSUinteger
@end


@implementation FEPlaceListSearchMapTVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    self.imageIdDict = [NSMutableDictionary dictionary];
}
#pragma mark - getter setter
- (void)setPlaces:(NSArray *)places {
    _places = places;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (NSUInteger)getImageIndexOfObjId:(NSManagedObjectID*)objId{
    NSNumber *index;
    index = self.imageIdDict[objId];
    if (index == nil) {
        index = @(0);
        self.imageIdDict[objId] = index;
    }
    return [index integerValue];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
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
    Place *place = self.places[index];
    if (place.photos.count != 0) {
        cell.delegate = self;
        cell.nameLbl.text = place.name;
        cell.addressLbl.text = place.address.address;
        cell.ratingView.rate = [place.rating integerValue];
        cell.flipPhotosView.rowIndex = index;
        cell.flipPhotosView.delegate = self;
        cell.flipPhotosView.usingThumbnail = YES;
        [cell.flipPhotosView setDatasource:[place.photos array]
                         withSelectedIndex:[self getImageIndexOfObjId:place.objectID]];
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
        CLLocationDistance distance = [place.distance doubleValue];
        if (distance != -1){
            if (distance < 1000) {
                cell.distanceLbl.text = [NSString stringWithFormat:@"About %d meters from here.", (int)distance];
            } else {
                cell.distanceLbl.text = [NSString stringWithFormat:@"About %.2f kilometers from here.", distance / 1000];
            }
        } else {
            cell.distanceLbl.text = @"";
        }
    }
    else {
        // TODO
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 89;
}
//#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // TODO
//}
#pragma mark - FEFlipPhotosViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    Place *place = self.places[row];
    self.imageIdDict[place.objectID] = @(index);
}
#pragma mark - FEPlaceListCellDelegate
- (void)didSelectPlaceDetailAtCell:(FEPlaceListCell *)cell {
    NSUInteger row = [[self.tableView indexPathForCell:cell] row];
    [self.searchDelegate searchMapDidSelectPlace:self.places[row]];
}

@end
