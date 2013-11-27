//
//  FEFoodGridCVC.m
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodGridCVC.h"
#import "FEFlipGridFoodView.h"
#import "Food+Extension.h"
#import "Photo.h"
#import "FEPlaceDetailMainVC.h"
#import "FEFoodSingleEditVC.h"
#import "OriginPhoto.h"
#import "FETransparentCustomSegue.h"

@interface FEFoodGridCVC()<FEFlipGridFoodViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageIndexes; // of NSUinteger
@property (nonatomic) NSUInteger selectedDetailIndex;
@property (nonatomic, strong) NSMutableArray *selectedStatusList;
@property (strong, nonatomic) NSArray *foods; // array of Foods
@property (strong, nonatomic) NSArray *foodsForDisplay; // array of displayed Foods
@property (strong, nonatomic) NSMutableArray *readyToPhotosList; // array of array of Photo
@property (strong, nonatomic) NSMutableDictionary *beingCompressedPhotosList; // dictionary of array of Photo
@property (strong, nonatomic) NSOperationQueue *operationQueue;
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
    // cancel all remain task
    [self.operationQueue cancelAllOperations];
    [self.operationQueue waitUntilAllOperationsAreFinished];
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
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
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
- (NSOperationQueue *)operationQueue {
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}
#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.foodsForDisplay.count;
}
#define kFlipFoodGridView   100
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"foodCell";
    
    Food *food = self.foodsForDisplay[indexPath.row];
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    FEFlipGridFoodView *flipFoodGridView = (FEFlipGridFoodView *)[cell viewWithTag:kFlipFoodGridView];
    flipFoodGridView.delegate = self;
    flipFoodGridView.cellIndex = indexPath.row;
    flipFoodGridView.isEditMode = self.isEditMode;
    flipFoodGridView.isSelected = [self.selectedStatusList[indexPath.row] boolValue];
    flipFoodGridView.name = food.name;
    flipFoodGridView.isBest = [food.isBest boolValue];
    flipFoodGridView.isLoading = NO;
    // No Photo Cell
    if (food.photos.count == 0) {
        [flipFoodGridView setDatasource:nil withSelectedIndex:0];
        return cell;
    }
    // Loading Cell
    NSMutableArray *compressedPhotos = self.readyToPhotosList[indexPath.row];
    if (compressedPhotos.count == 0) {
//        if (collectionView.dragging == NO && collectionView.decelerating == NO) {
            [self startCompressPhotos:compressedPhotos withSize:flipFoodGridView.frame.size forIndexPath:indexPath];
//        }
        flipFoodGridView.isLoading = YES;
        [flipFoodGridView setDatasource:nil withSelectedIndex:0];
        return cell;
    }
    // Normal Cell
    [flipFoodGridView setDatasource:compressedPhotos
                       withSelectedIndex:[self.imageIndexes[indexPath.row] integerValue]];
    return cell;
}
- (void)startCompressPhotos:(NSMutableArray*)compressedPhotos withSize:(CGSize)size forIndexPath:(NSIndexPath*)indexPath {
    // check Photo is not being compressed, then compress
    if (self.beingCompressedPhotosList[indexPath] == nil) {
        // mark as being compress at index
        self.beingCompressedPhotosList[indexPath] = @(YES);
        __weak FEFoodGridCVC* weakSelf = self;
        [self.operationQueue addOperationWithBlock:^{
            Food *food = weakSelf.foodsForDisplay[indexPath.row];
            // compress image
            for (Photo *photo in food.photos) {
                UIImage *originalImage = [UIImage imageWithData:photo.originPhoto.imageData];
                UIImage *resizeImage = [UIImage imageWithImage:originalImage scaledToSize:size];
                [compressedPhotos addObject:resizeImage];
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // TODO: this is not good, should wait Main queue finish
                if (indexPath.row >= weakSelf.imageIndexes.count) {
                    return;
                }
                // reload cell with Photos compressed
                UICollectionViewCell* cell = (UICollectionViewCell*)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                FEFlipGridFoodView *flipFoodGridView = (FEFlipGridFoodView *)[cell viewWithTag:kFlipFoodGridView];
                flipFoodGridView.isLoading = NO;
                [flipFoodGridView setDatasource:compressedPhotos
                              withSelectedIndex:[weakSelf.imageIndexes[indexPath.row] integerValue]];
                // remove mark (just for improvement)
                [self.beingCompressedPhotosList removeObjectForKey:indexPath];
            }];
        }];
    }
}
//#define FLIP_VIEW_SIZE CGSizeMake(140, 140)
//- (void)loadFoodsForOnscreenRows {
//    if ([self.readyToPhotosList count] > 0) {
//        NSArray *visibleItems = [self.collectionView indexPathsForVisibleItems];
//        for (NSIndexPath *indexPath in visibleItems) {
//            NSMutableArray *compressedPhotos = self.readyToPhotosList[indexPath.row];
//            if (compressedPhotos.count == 0) {
//                [self startCompressPhotos:compressedPhotos withSize:FLIP_VIEW_SIZE forIndexPath:indexPath];
//            }
//        }
//    }
//}
//
//#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    if (!decelerate){
//        [self loadFoodsForOnscreenRows];
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [self loadFoodsForOnscreenRows];
//}

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
