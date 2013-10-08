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

@interface FEFoodGridCVC()<FEFlipGridFoodViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (nonatomic) NSUInteger selectedDetailIndex;
@property (nonatomic, strong) NSMutableArray *selectedIndexList;
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
        Food *food = self.foods[self.selectedDetailIndex];
        placeDetailVC.place = food.owner;
    }
}

- (void)updateCell:(FEFoodGridCell*)cell atIndex:(NSUInteger)index{
    Food *food = self.foods[index];
    if (food.photos.count != 0) {
        cell.flipFoodGridView.name = food.name;
        cell.flipFoodGridView.isBest = [food.isBest boolValue];
        cell.flipFoodGridView.delegate = self;
        cell.flipFoodGridView.cellIndex = index;
        cell.flipFoodGridView.isEditMode = self.isEditMode;
        cell.flipFoodGridView.isSelected = [self.selectedIndexList[index] boolValue];
        [cell.flipFoodGridView setDatasource:[food.photos array]
                            withSelectedIndex:[self.imageIndexes[index] integerValue]];
    }
    else {
        // TODO
    }
}
- (void)updateFoodsWithSettingInfo:(FESearchFoodSettingInfo *)foodSetting {
    self.foods = [Food foodsFromFoodSettingInfo:foodSetting];
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.foods.count];
    self.selectedIndexList = [NSMutableArray arrayWithCapacity:self.foods.count];
    for (int i = 0; i< self.foods.count; i++) {
        [self.imageIndexes addObject:@(0)];
        [self.selectedIndexList addObject:@(NO)];
    }
    [self.collectionView reloadData];
}
#pragma mark - setter getter
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    if (isEditMode) {
        for (int i = 0; i< self.selectedIndexList.count; i++) {
            self.selectedIndexList[i] = @(NO);
        }
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
- (void)didSelectDetailPlaceAtIndex:(NSUInteger)index {
    self.selectedDetailIndex = index;
    [self performSegueWithIdentifier:@"placeDetail" sender:self];
}
- (void)didSelectCellAtIndex:(NSUInteger)index {
    self.selectedIndexList[index] = @(![self.selectedIndexList[index] boolValue]);
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}
@end
