//
//  FEDynamicScrollView.h
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEWiggleView.h"

@interface FEDynamicScrollView : UIScrollView
@property (nonatomic, strong) NSMutableArray *wiggleViews; // array of FEWiggleView
@property (nonatomic) BOOL editMode;
- (void)addView:(FEWiggleView*)wiggleView atIndex:(int)index;
@end
