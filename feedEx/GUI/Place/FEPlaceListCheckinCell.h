//
//  FEPlaceListCheckinCell.h
//  feedEx
//
//  Created by csnguyen on 9/9/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEFlipPhotosView.h"
@class FEPlaceListCheckinCell;
@protocol FEPlaceListCheckinCellDelegate<NSObject>
- (void)didSelectPlaceDetailAtCell:(FEPlaceListCheckinCell*)cell;
@end

@interface FEPlaceListCheckinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FEFlipPhotosView *flipPhotosView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *chekinInfoLbl;
@property (weak, nonatomic) IBOutlet UIButton *informationBtn;
@property (weak, nonatomic) id<FEPlaceListCheckinCellDelegate> delegate;

@end
