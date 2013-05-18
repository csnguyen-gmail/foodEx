//
//  FEDynamicScrollView.h
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEWiggleImageView.h"

@interface FEDynamicScrollView : UIScrollView <FEWiggleImageViewProtocol>
@property (nonatomic, strong) NSMutableArray *images; // array of UIImage
@property (nonatomic) BOOL editMode;
- (void)addImage:(UIImage*)image atIndex:(int)index;
@end
