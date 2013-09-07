//
//  FEFoodGridCVC.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodGridCVC.h"
#import "FEFoodGridCell.h"
#import "Food+Extension.h"
#import "Photo.h"
#import "FEPlaceDetailMainVC.h"
#import "FECoreDataController.h"

@interface FEFoodGridCVC()<FEFlipGridFoodViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (nonatomic) NSUInteger selectedRow;
@property (weak, nonatomic) FECoreDataController *coreData;
@property (strong, nonatomic) NSArray *foods; // array of Foods

@end
@implementation FEFoodGridCVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeDetail"]) {
        FEPlaceDetailMainVC *placeDetailVC = [segue destinationViewController];
        Food *food = self.foods[self.selectedRow];
        placeDetailVC.place = food.owner;
    }
}

- (void)updateCell:(FEFoodGridCell*)cell atIndex:(NSUInteger)index{
    Food *food = self.foods[index];
    if (food.photos.count != 0) {
        cell.flipPlaceGridView.name = food.name;
        cell.flipPlaceGridView.delegate = self;
        cell.flipPlaceGridView.rowIndex = index;
        [cell.flipPlaceGridView setDatasource:[food.photos array]
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
- (void)updateFoodsWithSettingInfo:(FESearchFoodSettingInfo *)foodSetting {
    self.foods = [Food foodsFromFoodSettingInfo:foodSetting withMOC:self.coreData.managedObjectContext];
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.foods.count];
    for (int i = 0; i< self.foods.count; i++) {
        [self.imageIndexes addObject:@(0)];
    }
    [self.collectionView reloadData];
}

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.foods.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"foodCell";
    FEFoodGridCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndex:indexPath.row];
    return cell;
}
#pragma mark - FEFlipGridFoodViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    self.imageIndexes[row] = @(index);
}
- (void)didSelectPlaceAtRow:(NSUInteger)row {
    self.selectedRow = row;
    [self performSegueWithIdentifier:@"placeDetail" sender:self];
}
@end
