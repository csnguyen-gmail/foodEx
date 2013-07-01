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

@interface FEPlaceListTVC ()
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
    [self updateCell:cell withPlaceInfo:self.places[indexPath.row]];
    return cell;
}

- (void)updateCell:(FEPlaceListCell*)cell withPlaceInfo:(Place*)place {
    cell.nameLbl.text = place.name;
    cell.addressLbl.text = place.address.address;
    cell.tagLbl.text = [place buildTagsString];
    cell.ratingView.rate = [place.rating integerValue];
    cell.thumbnailView.image = [[place.photos firstObject] thumbnailPhoto];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
}

@end
