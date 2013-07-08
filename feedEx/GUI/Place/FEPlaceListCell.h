//
//  FEPlaceListCell.h
//  feedEx
//
//  Created by csnguyen on 6/29/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import "FEFlipPhotosView.h"
@class FEPlaceListCell;
@protocol FEPlaceListCellDelegate<NSObject>
- (void)didSelectPlaceDetailAtCell:(FEPlaceListCell*)cell;
@end

@interface FEPlaceListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FEFlipPhotosView *flipPhotosView;
@property (weak, nonatomic) IBOutlet DYRateView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;
@property (weak, nonatomic) IBOutlet UIScrollView *tagsScrollView;
@property (weak, nonatomic) id<FEPlaceListCellDelegate> delegate;
@end
