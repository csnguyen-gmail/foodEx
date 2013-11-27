//
//  FEImagePickerPhotoVC.m
//  NewImagePicker
//
//  Created by csnguyen on 11/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerPhotoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FEImagePickerScrollView.h"
#import <QuartzCore/QuartzCore.h>

@interface FEImagePickerPhotoVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *groups; // array of array of ALAsset
@property (nonatomic, strong) NSMutableArray *groupsName; // array of NSString
// The lifetimes of objects you get back from a library instance are tied to the lifetime of the library instance.
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (weak, nonatomic) IBOutlet FEImagePickerScrollView *imageScrollView;
@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *indicationViews;
@property (strong, nonatomic) NSIndexPath *currentIndex;

@end

@implementation FEImagePickerPhotoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self startInidicationView];
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        [self loadImageFromPhoto];
    }];
}
- (void)loadImageFromPhoto {
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        [self stopIndicationView];
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                NSLog(@"The user has declined access to it.");
                break;
            default:
                NSLog(@"Reason unknown.");
                break;
        }
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            self.currentIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self displayImageAtSectionAtCurrentIndex];
                [self.collectionView reloadData];
                [self stopIndicationView];
            }];
        }
        else {
            [self.groupsName insertObject:[group valueForProperty:ALAssetsGroupPropertyName] atIndex:0];
            [self.groups insertObject:[self assetPhotos:group] atIndex:0];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];

}
- (void)startInidicationView {
    for (UIActivityIndicatorView *indicationView in self.indicationViews) {
        [indicationView startAnimating];
    }
}
- (void)stopIndicationView {
    for (UIActivityIndicatorView *indicationView in self.indicationViews) {
        [indicationView stopAnimating];
    }
}
- (NSMutableArray*)assetPhotos:(ALAssetsGroup*)assetsGroup {
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [assets insertObject:result atIndex:0];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [assetsGroup setAssetsFilter:onlyPhotosFilter];
    [assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    return assets;
}
- (void)displayImageAtSectionAtCurrentIndex {
    // load the asset for this cell
    if (self.groups.count == 0) {
        return;
    }
    NSArray *assets = self.groups[self.currentIndex.section];
    if (assets.count == 0) {
        return;
    }
    ALAsset *asset = assets[self.currentIndex.row];
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:UIImageOrientationUp];
    [self.imageScrollView displayImage:fullScreenImage];
}
#pragma mark - Event handler
- (IBAction)switchCameraTapped:(UIBarButtonItem *)sender {
    [self.delegate imagePickerPhotoSwithToCamera:self];
}
- (IBAction)cancelTapped:(UIBarButtonItem *)sender {
    [self.delegate imagePickerPhoto:self didFinishWithImage:nil];
}
- (IBAction)cropTapped:(UIBarButtonItem *)sender {
    [self.delegate imagePickerPhoto:self didFinishWithImage:[self.imageScrollView croppedImage]];
}

#pragma mark - Rotation controller
-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientation{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - getter setter
- (NSMutableArray *)groups {
    if (_groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    }
    return _groups;
}
-(NSMutableArray *)groupsName {
    if (_groupsName == nil) {
        _groupsName = [[NSMutableArray alloc] init];
    }
    return _groupsName;
}
#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.groups.count;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.groups[section] count];
}

#define kImageViewTag   100
#define kHeaderLabelTag 101

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"thumbnailCell";
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    ALAsset *asset = self.groups[indexPath.section][indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    // apply the image to the cell
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
    imageView.layer.cornerRadius = 10.0;
    imageView.layer.masksToBounds = YES;
    if ([indexPath compare:self.currentIndex] == NSOrderedSame) {
        imageView.layer.borderWidth = 2.0;
        imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    }
    else {
        imageView.layer.borderWidth = 0.0;
    }
    imageView.image = thumbnail;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    static NSString *headerIdentifier = @"header";
    
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        UILabel *headerLbl = (UILabel *)[reusableview viewWithTag:kHeaderLabelTag];
        headerLbl.text = self.groupsName[indexPath.section];
    }
    return reusableview;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentIndex = indexPath;
    [self displayImageAtSectionAtCurrentIndex];
    [collectionView reloadData];
}
@end
