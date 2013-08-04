//
//  FEPlaceDetailTVC.m
//  feedEx
//
//  Created by csnguyen on 7/28/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceDetailTVC.h"
#import "DYRateView.h"
#import "Tag.h"
#import "Photo.h"
#import "FEPlaceDetailFoodCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FEFlipPlaceView.h"

@interface FEPlaceDetailTVC()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *tagsScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *foodCollectionView;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet FEFlipPlaceView *flipPlaceView;
@end

@implementation FEPlaceDetailTVC
#define TAG_PADDING 5.0
#define TAG_HORIZON_MARGIN 10.0
#define TAG_VERTICAL_MARGIN 5.0
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.tableView.layer.cornerRadius = 10;
    
    self.noteTextView.layer.cornerRadius = 10;
    self.noteTextView.layer.borderWidth = 1;
    self.noteTextView.layer.borderColor = [[UIColor grayColor] CGColor];
}
- (void)setPlace:(Place *)place {
    _place = place;
    self.flipPlaceView.name = place.name;
    self.flipPlaceView.rating = [place.rating integerValue];
    [self.flipPlaceView setDatasource:[place.photos array] withSelectedIndex:0];
    self.noteTextView.text = self.place.note;
    if (self.place.tags.count > 0) {
        CGFloat contentWidth = 0.0;
        for (Tag *tag in self.place.tags) {
            UIFont *font = [UIFont systemFontOfSize:10];
            CGSize tagSize = [tag.label sizeWithFont:font];
            tagSize.height = self.tagsScrollView.frame.size.height;
            tagSize.width += TAG_HORIZON_MARGIN;
            UILabel *tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth, 0, tagSize.width, tagSize.height)];
            tagLbl.textAlignment = NSTextAlignmentCenter;
//            tagLbl.adjustsFontSizeToFitWidth = YES;
//            tagLbl.minimumScaleFactor = 0.1;
            tagLbl.text = [NSString stringWithFormat:@" %@ ", tag.label];
            tagLbl.font = font;
            tagLbl.textColor = [UIColor whiteColor];
            tagLbl.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.2];
            tagLbl.layer.cornerRadius = 5;
            tagLbl.layer.borderColor = [[UIColor whiteColor] CGColor];
            tagLbl.layer.borderWidth = 0.8;
            [self.tagsScrollView addSubview:tagLbl];
            contentWidth += tagSize.width + TAG_PADDING;
        }
        CGSize size = self.tagsScrollView.contentSize;
        size.width = contentWidth;
        self.tagsScrollView.contentSize = size;
    }
    [self.foodCollectionView reloadData];
}
#pragma mark - common
- (void)updateCell:(FEPlaceDetailFoodCell*)cell withFood:(Food*)food atIndexPath:(NSIndexPath*)indexPath {
    cell.food = food;
}

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.place.foods.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"foodCell";
    FEPlaceDetailFoodCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell withFood:self.place.foods[indexPath.row] atIndexPath:indexPath];
    return cell;
}
#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.placeDetailTVCDelegate didSelectItemAtIndexPath:indexPath.row];
}
@end
