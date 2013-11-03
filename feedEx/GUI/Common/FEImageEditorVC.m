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
@interface FEImageEditorVC ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSMutableArray *filterImages;
@property (strong, nonatomic) NSMutableArray *filters;
@property (strong, nonatomic) CIContext *context;
@end

@implementation FEImageEditorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.context = [CIContext contextWithOptions:nil];
    self.filters = [NSMutableArray array];
    self.filterImages = [NSMutableArray array];
    [self.filterImages addObject:[UIImage imageNamed:@"CISample"]];
    // build filters
    CIFilter *filter;
    
    filter = [CIFilter filterWithName:@"CIUnsharpMask"];
    [filter setValue:@(100.0) forKey:@"inputRadius"];
    [filter setValue:@(0.5) forKey:@"inputIntensity"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CIUnsharpMask"]];
    
    filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:@(1.0) forKey:@"inputIntensity"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CISepiaTone"]];
    
    filter = [CIFilter filterWithName:@"CIVibrance"];
    [filter setValue:@(1.0) forKey:@"inputAmount"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CIVibrance"]];
    
    filter = [CIFilter filterWithName:@"CIVignette"];
    [filter setValue:@(2.0) forKey:@"inputRadius"];
    [filter setValue:@(1.0) forKey:@"inputIntensity"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CIVignette"]];

    filter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    [filter setValue:[CIVector vectorWithX:15000 Y:0] forKey:@"inputNeutral"];
    [filter setValue:[CIVector vectorWithX:6500 Y:0] forKey:@"inputTargetNeutral"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CITemperatureAndTint"]];
    
    filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:@(2.0) forKey:@"inputSaturation"];
    [filter setValue:@(0.0) forKey:@"inputBrightness"];
    [filter setValue:@(1.0) forKey:@"inputContrast"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CIColorControls"]];
    
    filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    [filter setValue:@(-1.0) forKey:@"inputShadowAmount"];
    [filter setValue:@(0.3) forKey:@"inputHighlightAmount"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CIHighlightShadowAdjustDown"]];
    
    filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    [filter setValue:@(8.0) forKey:@"inputShadowAmount"];
    [filter setValue:@(1.0) forKey:@"inputHighlightAmount"];
    [self.filters addObject:filter];
    [self.filterImages addObject:[UIImage imageNamed:@"CIHighlightShadowAdjustUp"]];
}

- (IBAction)resetTapped:(id)sender {
    self.cropRect = CGRectMake((self.frameView.frame.size.width-320)/2.0f, (self.frameView.frame.size.height-320)/2.0f, 320, 320);
    [self reset:YES];
}

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterImages.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"effectCell";
    FEImageEditorCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.effectImageView.image = self.filterImages[indexPath.row];
    return cell;
}
#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}



@end
