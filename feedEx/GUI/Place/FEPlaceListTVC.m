//
//  FEPlaceListTVC.m
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceListTVC.h"
#import "FEPlaceListCell.h"
@interface FEPlaceListTVC ()

@end

@implementation FEPlaceListTVC
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FEPlaceListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FEPlaceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.ratingView setupSmallStarEditable:NO];
    cell.nameLbl.text = [NSString stringWithFormat:@"Name%d", indexPath.row];
    cell.addressLbl.text = [NSString stringWithFormat:@"Address%d", indexPath.row];
    cell.tagLbl.text = [NSString stringWithFormat:@"Tag%d", indexPath.row];
    cell.ratingView.rate = indexPath.row % 6;

    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
}

@end
