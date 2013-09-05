//
//  FEFoodGridCVC.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodGridCVC.h"
#import "FEFoodGridCell.h"
#import "Place.h"
#import "Photo.h"
#import "FEPlaceDetailMainVC.h"
#import <QuartzCore/QuartzCore.h>
@interface FEFoodGridCVC()<FEFlipGridFoodViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (nonatomic) NSUInteger selectedRow;
@end
@implementation FEFoodGridCVC
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.collectionView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
//    self.collectionView.layer.cornerRadius = 10;
    self.collectionView.backgroundColor = [UIColor clearColor];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeDetail"]) {
        FEPlaceDetailMainVC *placeDetailVC = [segue destinationViewController];
        placeDetailVC.place = self.placeDataSource.places[self.selectedRow];
    }
}

- (void)updateCell:(FEFoodGridCell*)cell atIndex:(NSUInteger)index{
    Place *place = self.placeDataSource.places[index];
    if (place.photos.count != 0) {
        cell.flipPlaceGridView.rating = [place.rating integerValue];
        cell.flipPlaceGridView.name = place.name;
        cell.flipPlaceGridView.delegate = self;
        cell.flipPlaceGridView.rowIndex = index;
        [cell.flipPlaceGridView setDatasource:[place.photos array]
                            withSelectedIndex:[self.imageIndexes[index] integerValue]];
    }
    else {
        // TODO
    }
}
#pragma mark - getter setter
- (void)setPlaceDataSource:(FEPlaceDataSource *)placeDataSource {
    _placeDataSource = placeDataSource;
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.placeDataSource.places.count];
    for (int i = 0; i< self.placeDataSource.places.count; i++) {
        [self.imageIndexes addObject:@(0)];
    }
    [self.collectionView reloadData];
}

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.placeDataSource.places.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"placeCell";
    FEFoodGridCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndex:indexPath.row];
    return cell;
}
//#pragma mark - Collection view delegate
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//}
#pragma mark - FEFlipGridFoodViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    self.imageIndexes[row] = @(index);
}
- (void)didSelectPlaceAtRow:(NSUInteger)row {
    self.selectedRow = row;
    [self performSegueWithIdentifier:@"placeDetail" sender:self];
}
@end
