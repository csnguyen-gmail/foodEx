//
//  FEDynamicScrollView.h
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEWiggleView.h"

@protocol FEDynamicScrollViewDelegate <NSObject>
@optional
- (void)enterDraggingMode;
- (void)exitDraggingMode;
- (void)enterEditMode;
@required
- (void)removeImageAtIndex:(NSUInteger)index;
- (void)viewMovedFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
@end

@interface FEDynamicScrollView : UIScrollView
@property (nonatomic, strong) NSMutableArray *wiggleViews; // array of FEWiggleView
@property (nonatomic) BOOL editMode;
@property (nonatomic, weak) id<FEDynamicScrollViewDelegate> dynamicScrollViewDelegate;
@property (nonatomic) BOOL hasChanges;

- (void)addView:(FEWiggleView *)wiggleView atIndex:(int)index withAnimation:(BOOL)animated;
- (void)setupWithWiggleArray:(NSArray*)wiggles withAnimation:(BOOL)animated;
@end
