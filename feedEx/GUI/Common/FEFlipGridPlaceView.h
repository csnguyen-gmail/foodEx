//
//  FEFlipGridPlaceView.h
//  feedEx
//
//  Created by csnguyen on 8/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEFlipListView.h"

@protocol FEFlipGridPlaceViewDelegate<NSObject>
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row;
- (void)didSelectPlaceAtRow:(NSUInteger)row;
@end

@interface FEFlipGridPlaceView : FEFlipListView
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSUInteger rating;
@property (nonatomic) NSUInteger rowIndex;
@property (nonatomic, weak) id<FEFlipGridPlaceViewDelegate> delegate;
@end
