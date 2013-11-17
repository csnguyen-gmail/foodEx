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
#import "FEFoodSingleEditVC.h"
#import "OriginPhoto.h"
#import "FETransparentCustomSegue.h"

@interface FEFoodGridCVC()<FEFlipGridFoodViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (nonatomic) NSUInteger selectedDetailIndex;
@property (nonatomic, strong) NSMutableArray *selectedStatusList;
@property (strong, nonatomic) NSArray *foods; // array of Foods
@property (strong, nonatomic) NSArray *foodsForDisplay; // array of displayed Foods
@property (strong, nonatomic) NSMutableArray *readyToPhotosList; // array of array of Photo
@property (strong, nonatomic) NSMutableDictionary *beingCompressedPhotosList; // dictionary of array of Photo
@end
@implementation FEFoodGridCVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor clearColor];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeDetail"]) {
        FEPlaceDetailMainVC *placeDetailVC = [segue destinationViewController];
        Food *food = self.foodsForDisplay[self.selectedDetailIndex];
        placeDetailVC.place = food.owner;
    }
    else if ([[segue identifier] isEqualToString:@"foodSingleEdit"]) {
        // we need TransparentCustomSegue cover all screen, not only in FoodGridCVC
        FETransparentCustomSegue *customSegue = (FETransparentCustomSegue*)segue;

        customSegue.sourceVC = self.parentViewController;
        FEFoodSingleEditVC *foodSingleEditlVC = [segue destinationViewController];
        Food *food = self.foodsForDisplay[self.selectedDetailIndex];
        foodSingleEditlVC.food = food;
    }
}

- (void)updateFoodsWithSettingInfo:(FESearchFoodSettingInfo *)foodSetting {
    // get data
    self.foods = [Food foodsFromFoodSettingInfo:foodSetting];
    self.quickSearchString = nil;
}
- (NSArray *)getSelectedFoods {
    NSMutableArray *foods = [NSMutableArray array];
    for (int i = 0; i < self.selectedStatusList.count; i++) {
        if ([self.selectedStatusList[i] boolValue]) {
            [foods addObject:self.foodsForDisplay[i]];
        }
    }
    return foods;
}
#pragma mark - setter getter
- (void)setQuickSearchString:(NSString *)quickSearchString {
    _quickSearchString = quickSearchString;
    // filtering
    if (quickSearchString.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", quickSearchString];
        self.foodsForDisplay = [self.foods filteredArrayUsingPredicate:predicate];
    }
    else {
        self.foodsForDisplay = self.foods;
    }
    // reset
    self.imageIndexes = [NSMutableArray arrayWithCapacity:self.foodsForDisplay.count];
    self.selectedStatusList = [NSMutableArray arrayWithCapacity:self.foodsForDisplay.count];
    for (int i = 0; i< self.foodsForDisplay.count; i++) {
        [self.imageIndexes addObject:@(0)];
        [self.selectedStatusList addObject:@(NO)];
    }
    // reset readyPhotosList & beingCompressedPhotosList
    self.readyToPhotosList = [NSMutableArray arrayWithCapacity:self.foodsForDisplay.count];
    for (int i = 0; i < self.foodsForDisplay.count; i++) {
        self.readyToPhotosList[i] = [NSMutableArray array];
    }
    self.beingCompressedPhotosList = [NSMutableDictionary dictionaryWithCapacity:self.foodsForDisplay.count];
    // update GUI
    // TODO: animation
    [self.collectionView reloadData];
}
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    if (isEditMode) {
        for (int i = 0; i< self.selectedStatusList.count; i++) {
            self.selectedStatusList[i] = @(NO);
        }
    }
    [self.collectionView reloadData];
}
#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.foodsForDisplay.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"foodCell";
    
    Food *food = self.foodsForDisplay[indexPath.row];
    FEFoodGridCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.flipFoodGridView.delegate = self;
    cell.flipFoodGridView.cellIndex = indexPath.row;
    cell.flipFoodGridView.isEditMode = self.isEditMode;
    cell.flipFoodGridView.isSelected = [self.selectedStatusList[indexPath.row] boolValue];
    cell.flipFoodGridView.name = food.name;
    cell.flipFoodGridView.isBest = [food.isBest boolValue];
    // No Photo Cell
    if (food.photos.count == 0) {
        [cell.flipFoodGridView setDatasource:nil withSelectedIndex:0];
        return cell;
    }
    // Loading Cell
    NSMutableArray *compressedPhotos = self.readyToPhotosList[indexPath.row];
    if (compressedPhotos.count == 0) {
        [self startCompressPhotos:compressedPhotos withSize:cell.flipFoodGridView.frame.size forIndexPath:indexPath];
        [cell.flipFoodGridView setDatasource:nil withSelectedIndex:0];
        return cell;
    }
    // Normal Cell
    [cell.flipFoodGridView setDatasource:compressedPhotos
                       withSelectedIndex:[self.imageIndexes[indexPath.row] integerValue]];
    return cell;
}
- (void)startCompressPhotos:(NSMutableArray*)compressedPhotos withSize:(CGSize)size forIndexPath:(NSIndexPath*)indexPath {
    // check Photo is not being compressed, then compress
    if (self.beingCompressedPhotosList[indexPath] == nil) {
        // mark as being compress at index
        self.beingCompressedPhotosList[indexPath] = @(YES);
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue addOperationWithBlock:^{
            // TODO: CRASH
            Food *food = self.foodsForDisplay[indexPath.row];
            // compress image
            for (Photo *photo in food.photos) {
                UIImage *originalImage = [UIImage imageWithData:photo.originPhoto.imageData];
                UIImage *resizeImage = [UIImage imageWithImage:originalImage scaledToSize:size];
                [compressedPhotos addObject:resizeImage];
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // reload cell with Photos compressed
                FEFoodGridCell* cell = (FEFoodGridCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell.flipFoodGridView setDatasource:compressedPhotos
                                   withSelectedIndex:[self.imageIndexes[indexPath.row] integerValue]];
                // remove mark (just for improvement)
                [self.beingCompressedPhotosList removeObjectForKey:indexPath];
            }];
        }];
    }
}
#pragma mark - FEFlipGridFoodViewDelegate
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row {
    self.imageIndexes[row] = @(index);
}
- (void)didSelectDetailPlaceAtIndex:(NSUInteger)index {
    self.selectedDetailIndex = index;
    if (self.isEditMode) {
        [self performSegueWithIdentifier:@"foodSingleEdit" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"placeDetail" sender:self];
    }
}
- (void)didSelectCellAtIndex:(NSUInteger)index {
    self.selectedStatusList[index] = @(![self.selectedStatusList[index] boolValue]);
    // prevent reloadItemsAtIndexPaths animation. Is it Apple bug?
    [UIView setAnimationsEnabled:NO];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:YES];
    }];
    
    [self.foodGridDelegate didSelectFoodItem];
}
@end
