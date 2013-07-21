//
//  FEPlaceDetailVC.m
//  feedEx
//
//  Created by csnguyen on 7/8/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceDetailVC.h"
#import "DYRateView.h"
#import "Photo.h"
#import "Tag.h"
#import <QuartzCore/QuartzCore.h>
#import "FEPlaceEditMainVC.h"
#import "FEPlaceDetailFoodCell.h"

@interface FEPlaceDetailVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLbl;
@property (weak, nonatomic) IBOutlet DYRateView *ratingView;
@property (weak, nonatomic) IBOutlet UIScrollView *tagsScrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@end

@implementation FEPlaceDetailVC
#define TAG_PADDING 5.0
#define TAG_HORIZON_MARGIN 10.0
#define TAG_VERTICAL_MARGIN 5.0
- (void)viewDidLoad {
    [super viewDidLoad];
    self.placeNameLbl.text = self.place.name;
    self.ratingView.rate = [self.place.rating floatValue];
    self.placeImageView.image = [[UIImage alloc] initWithData:[[self.place.photos firstObject] imageData]];
    self.backgroundView.layer.cornerRadius = 10.0;
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.backgroundView.layer.borderWidth = 2.0;

    if (self.place.tags.count > 0) {
        CGFloat contentWidth = 0.0;
        for (Tag *tag in self.place.tags) {
            UIFont *font = [UIFont systemFontOfSize:10];
            CGSize tagSize = [tag.label sizeWithFont:font];
            tagSize.width += TAG_HORIZON_MARGIN;
            tagSize.height += TAG_VERTICAL_MARGIN;
            UILabel *tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth, 0, tagSize.width, tagSize.height)];
            tagLbl.textAlignment = NSTextAlignmentCenter;
            tagLbl.text = tag.label;
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

}
- (IBAction)editPlaceBtnTapped:(UIBarButtonItem *)sender {
    UINavigationController *editPlaceNav = [self.storyboard instantiateViewControllerWithIdentifier:@"editPlaceNavigation"];
    FEPlaceEditMainVC *editPlaceInfoMainVC = editPlaceNav.viewControllers[0];
    editPlaceInfoMainVC.placeInfo = self.place;
    [self presentModalViewController:editPlaceNav animated:YES];
}
#pragma mark - common
- (void)updateCell:(FEPlaceDetailFoodCell*)cell withFood:(Food*)food atIndexPath:(NSIndexPath*)indexPath {
    cell.food = food;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.place.foods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"foodCell";
    FEPlaceDetailFoodCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FEPlaceDetailFoodCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self updateCell:cell withFood:self.place.foods[indexPath.row] atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

@end
