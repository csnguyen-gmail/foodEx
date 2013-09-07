//
//  FEFlipGridFoodView.h
//  feedEx
//
//  Created by csnguyen on 8/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEFlipListView.h"

@protocol FEFlipGridFoodViewDelegate<NSObject>
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row;
- (void)didSelectPlaceAtRow:(NSUInteger)row;
@end

@interface FEFlipGridFoodView : FEFlipListView
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSUInteger isBest;
@property (nonatomic) NSUInteger rowIndex;
@property (nonatomic, weak) id<FEFlipGridFoodViewDelegate> delegate;
@end
