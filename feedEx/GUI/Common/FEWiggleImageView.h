//
//  FEWiggleImageView.h
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FEWiggleImageView : UIImageView
@property (nonatomic) BOOL roundedCorner;
@property (nonatomic, strong) UIView *additionalView;
- (void)appearDraggable;
- (void)appearNormal;
- (void)startWiggling;
- (void)stopWiggling;
@end
