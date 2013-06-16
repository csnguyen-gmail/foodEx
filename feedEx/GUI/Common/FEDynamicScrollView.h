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
- (void)enterDraggingMode;
- (void)exitDraggingMode;
- (void)enterEditMode;
- (void)removeImageAtIndex:(NSUInteger)index;
@end

@interface FEDynamicScrollView : UIScrollView
@property (nonatomic, strong) NSMutableArray *wiggleViews; // array of FEWiggleView
@property (nonatomic) BOOL editMode;
@property (nonatomic, weak) id<FEDynamicScrollViewDelegate> dynamicScrollViewDelegate;

- (void)addView:(FEWiggleView*)wiggleView atIndex:(int)index;
@end
