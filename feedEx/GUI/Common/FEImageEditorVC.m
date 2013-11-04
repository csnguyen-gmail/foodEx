//
//  FEImageEditorVC.m
//  feedEx
//
//  Created by csnguyen on 10/26/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImageEditorVC.h"
#import "HFImageEditorViewController+Private.h"
#import "FEImageEditorCell.h"
@interface FEFilterData : NSObject
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) CIFilter *filter;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL selected;
@end
@implementation FEFilterData
@end

@interface FEImageEditorVC ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSMutableArray *filters; // array of FEFilterData
@property (strong, nonatomic) CIContext *context;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (weak, nonatomic) IBOutlet UIImageView *testImage;
@property (weak, nonatomic) IBOutlet UICollectionView *filterSelectionView;
@end

@implementation FEImageEditorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    filter = [CIFilter filterWithName:@"CIUnsharpMask"];
    [filter setValue:@(100.0) forKey:@"inputRadius"];
    [filter setValue:@(0.5) forKey:@"inputIntensity"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CIUnsharpMask"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Sharp";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:@(1.0) forKey:@"inputIntensity"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CISepiaTone"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Sepia";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIVibrance"];
    [filter setValue:@(1.0) forKey:@"inputAmount"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CIVibrance"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Vibrance";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIVignette"];
    [filter setValue:@(2.0) forKey:@"inputRadius"];
    [filter setValue:@(1.0) forKey:@"inputIntensity"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CIVignette"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Vignette";
    [self.filters addObject:filterData];

    filter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    [filter setValue:[CIVector vectorWithX:15000 Y:0] forKey:@"inputNeutral"];
    [filter setValue:[CIVector vectorWithX:6500 Y:0] forKey:@"inputTargetNeutral"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CITemperatureAndTint"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"TempTint";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:@(2.0) forKey:@"inputSaturation"];
    [filter setValue:@(0.0) forKey:@"inputBrightness"];
    [filter setValue:@(1.0) forKey:@"inputContrast"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CIColorControls"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Color";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    [filter setValue:@(-1.0) forKey:@"inputShadowAmount"];
    [filter setValue:@(0.3) forKey:@"inputHighlightAmount"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CIHighlightShadowAdjustDown"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Hi-Sha Dec";
    [self.filters addObject:filterData];
    
    filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    [filter setValue:@(0.5) forKey:@"inputShadowAmount"];
    [filter setValue:@(1.0) forKey:@"inputHighlightAmount"];
    filterData = [[FEFilterData alloc] init];
    filterData.image = [UIImage imageNamed:@"CIHighlightShadowAdjustUp"];
    filterData.selected = NO;
    filterData.filter = filter;
    filterData.name = @"Hi-Sha Inc";
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
        self.imageView.image = self.sourceImage;
    }
    else {
        [self renderWithEffect:filterData.filter];
    }
}
- (void)renderWithEffect:(CIFilter*)filter {
    // TODO: Memory leak here
    [self.indicationView startAnimating];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        // apply effect
        CIImage *resultImage = [CIImage imageWithCGImage:[self.sourceImage CGImage]];
        [filter setValue:resultImage forKey:kCIInputImageKey];
        resultImage = filter.outputImage;
        //        CGImageRef cgimg = [self.context createCGImage:resultImage fromRect:[resultImage extent]];
        //        UIImage *outImage = [UIImage imageWithCGImage:cgimg scale:self.sourceImage.scale orientation:self.sourceImage.imageOrientation];
        UIImage *outImage = [UIImage imageWithCIImage:resultImage scale:[[UIScreen mainScreen] scale] orientation:self.sourceImage.imageOrientation];
        //        CGImageRelease(cgimg);
        // update GUI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = outImage;
            [self.indicationView stopAnimating];
        }];
    }];
}

#pragma mark - action hendler
- (IBAction)resetTapped:(id)sender {
    [self selectEffectAtIndex:0];
    self.cropRect = CGRectMake((self.frameView.frame.size.width-320)/2.0f, (self.frameView.frame.size.height-320)/2.0f, 320, 320);
    [self reset:YES];
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
    FEImageEditorCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
