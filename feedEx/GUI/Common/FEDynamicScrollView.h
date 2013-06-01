//
//  FEDynamicScrollView.h
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEWiggleView.h"

@protocol FEDynamicScrollViewProtocol <NSObject>
- (void)enterDraggingMode;
- (void)exitDraggingMode;
- (void)enterEditMode;
@end

@interface FEDynamicScrollView : UIScrollView
@property (nonatomic, strong) NSMutableArray *wiggleViews; // array of FEWiggleView
@property (nonatomic) BOOL editMode;
@property (nonatomic, weak) id<FEDynamicScrollViewProtocol> dynamicScrollViewDelegate;

- (void)addView:(FEWiggleView*)wiggleView atIndex:(int)index;
@end
