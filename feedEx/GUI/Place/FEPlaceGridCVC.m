//
//  FEPlaceGridCVC.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceGridCVC.h"
#import "FEPlaceGridCell.h"
#import "Place.h"
#import "Photo.h"

@implementation FEPlaceGridCVC
- (void)updateCell:(FEPlaceGridCell*)cell atIndex:(NSUInteger)index{
    Place *place = self.places[index];
    Photo *photo = place.photos[0];
    UIImage *image = [[UIImage alloc] initWithData:photo.imageData];
    cell.placeImageView.image = image;
}
#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.places.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"placeCell";
    FEPlaceGridCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndex:indexPath.row];
    return cell;
}
#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}

@end
