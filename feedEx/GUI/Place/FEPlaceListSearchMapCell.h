//
//  FEPlaceListSearchMapCell.h
//  feedEx
//
//  Created by csnguyen on 8/31/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FEPlaceListSearchMapCell;
@protocol FEPlaceListSearchMapCellDelegate<NSObject>
- (void)didSelectPlaceDetailAtCell:(FEPlaceListSearchMapCell*)cell;
@end

@interface FEPlaceListSearchMapCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;
@property (weak, nonatomic) id<FEPlaceListSearchMapCellDelegate> delegate;
@end
