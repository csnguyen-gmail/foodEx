//
//  FEFlipPlaceView.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEFlipListView.h"

@interface FEFlipPlaceView : FEFlipListView
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSUInteger rating;
@property (nonatomic) NSUInteger timesCheckin;
@end
