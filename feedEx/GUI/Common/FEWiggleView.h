//
//  FEWiggleView.h
//  feedEx
//
//  Created by csnguyen on 5/19/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEWiggleView : UIView
- (id)initWithMainView:(UIView*)mainView deleteView:(UIView*)deleteView;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *deleteView;
@property (nonatomic) BOOL editMode;
@property (nonatomic) BOOL dragMode;
@end
