//
//  FEVerticalResizeControllView.h
//  feedEx
//
//  Created by csnguyen on 5/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FEVerticalResizeControlDelegate <NSObject>
- (void)verticalResizeControllerDidChanged:(float) delta;
- (void)verticalResizeControllerDidTapped;
@end

@interface FEVerticalResizeControllView : UIView
@property (nonatomic, weak) id<FEVerticalResizeControlDelegate> delegate;
@end
