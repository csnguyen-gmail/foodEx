//
//  FEFoodGridCVC.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodGridCVC.h"
#import "FEFoodGridCell.h"
#import "Place+Extension.h"
#import "Photo.h"
#import "FEPlaceDetailMainVC.h"
#import "FECoreDataController.h"

@interface FEFoodGridCVC()<FEFlipGridFoodViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (nonatomic) NSUInteger selectedRow;
@property (weak, nonatomic) FECoreDataController *coreData;
@property (strong, nonatomic) NSArray *places; // array of Places

@end
@implementation FEFoodGridCVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeDetail"]) {
        FEPlaceDetailMainVC *placeDetailVC = [segue destinationViewController];
        placeDetailVC.place = self.places[self.selectedRow];
    }
}

- (void)updateCell:(FEFoodGridCell*)cell atIndex:(NSUInteger)index{
    Place *place = self.places[index];
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
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
- (void)updatePlacesWithSettingInfo:(FESearchPlaceSettingInfo *)placeSetting {
    self.places = [Place placesFromPlaceSettingInfo:placeSetting withMOC:self.coreData.managedObjectContext];
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.places.count];
    for (int i = 0; i< self.places.count; i++) {
        [self.imageIndexes addObject:@(0)];
    }
    [self.collectionView reloadData];
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
