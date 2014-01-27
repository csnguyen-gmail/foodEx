//
//  FEImagePickerEditVC.m
//  NewImagePicker
//
//  Created by csnguyen on 11/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerEditVC.h"
#import "FEImagePickerEditCell.h"

@interface FEFilterData : NSObject
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) CIFilter *filter;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL selected;
@end
@implementation FEFilterData
@end


@interface FEImagePickerEditVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (weak, nonatomic) IBOutlet UICollectionView *filterSelectionView;
@property (strong, nonatomic) NSMutableArray *filters; // array of FEFilterData
@property (strong, nonatomic) CIContext *context;
@end

@implementation FEImagePickerEditVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.imageView.image = self.image;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self loadFilter];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.filterSelectionView reloadData];
        }];
    }];
}

- (void)loadFilter {
    self.context = [CIContext contextWithOptions:nil];
    self.filters = [NSMutableArray array];
    
    FEFilterData *filterData;
    CIFilter *filter;
    // normal filter
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CISample"];
    filterData.selected = YES;
    filterData.filter = nil;
    filterData.name = @"Normal";
    [self.filters addObject:filterData];
    
    // built-in filters
    filter = [CIFilter filterWithName:@"CIPhotoEffectChrome"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:filter.name];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Chrome";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIPhotoEffectFade"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:filter.name];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Fade";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:filter.name];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Instant";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:filter.name];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Noir";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:filter.name];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Process";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:filter.name];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Transfer";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CILinearToSRGBToneCurve"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:filter.name];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Tone Curve";
    [self.filters addObject:filterData];
}

- (void)selectEffectAtIndex:(NSUInteger)index {
    FEFilterData *filterData = self.filters[index];
    // already selected then pass
    if (filterData.selected) {
        return;
    }
    // reset others selected items
    for (FEFilterData *filterData in self.filters) {
        if (filterData.selected) {
            filterData.selected = NO;
        }
    }
    // selected
    filterData.selected = YES;
    [self.filterSelectionView reloadData];
    // apply effect
    if (filterData.filter == nil) {
        self.imageView.image = self.image;
    }
    else {
        [self renderWithEffect:filterData.filter];
    }
}
- (void)renderWithEffect:(CIFilter*)filter {
    [self.indicationView startAnimating];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        // apply effect
        CIImage *resultImage = [CIImage imageWithCGImage:[self.image CGImage]];
        [filter setValue:resultImage forKey:kCIInputImageKey];
        resultImage = filter.outputImage;
        UIImage *outImage = [UIImage imageWithCIImage:resultImage
                                                scale:[[UIScreen mainScreen] scale]
                                          orientation:self.image.imageOrientation];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = outImage;
            [self.indicationView stopAnimating];
        }];
    }];
}
#pragma mark - Rotation controller
-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientation{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Event handler
- (IBAction)deleteTapped:(UIBarButtonItem *)sender {
    [self.delegate imagePickerEdit:self didFinishWithImage:nil];
}
- (IBAction)selectTapped:(UIBarButtonItem *)sender {
    [self.delegate imagePickerEdit:self didFinishWithImage:self.imageView.image];
}
- (IBAction)retakeTapped:(UIBarButtonItem *)sender {
    [self.delegate imagePickerEditRetake:self];
}
#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"effectCell";
    FEImagePickerEditCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    FEFilterData *filterData = self.filters[indexPath.row];
    cell.effectImageView.image = filterData.image;
    cell.name.text = filterData.name;
    [cell setSelectedStyle:filterData.selected];
    
    return cell;
}
#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self selectEffectAtIndex:indexPath.row];
}

@end
