//
//  FEFlipImageListView.h
//  feedEx
//
//  Created by csnguyen on 7/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEFlipListView : UIView
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic) NSUInteger currentViewIndex;

- (void)setDatasource:(NSArray *)datasource withSelectedIndex:(NSUInteger)index;
- (UIView*)getViewAtIndex:(NSUInteger)index; // abstract function
@end
