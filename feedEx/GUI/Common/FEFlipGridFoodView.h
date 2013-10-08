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
- (void)didSelectDetailPlaceAtIndex:(NSUInteger)index;
- (void)didSelectCellAtIndex:(NSUInteger)index;
@end

@interface FEFlipGridFoodView : FEFlipListView
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSUInteger isBest;
@property (nonatomic) NSUInteger cellIndex;
@property (nonatomic, weak) id<FEFlipGridFoodViewDelegate> delegate;
@property (nonatomic) BOOL isEditMode;
@property (nonatomic) BOOL isSelected;
@end
