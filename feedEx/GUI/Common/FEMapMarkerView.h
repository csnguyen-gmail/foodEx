//
//  FEMapMarkerView.h
//  feedEx
//
//  Created by csnguyen on 11/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface FEMapMarkerView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet DYRateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet UILabel *distanceLbl;
@property (weak, nonatomic) IBOutlet UILabel *checkinLbl;
@property (weak, nonatomic) IBOutlet UIScrollView *tagsScrollView;

@end
