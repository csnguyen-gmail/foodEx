//
//  FEFoodDetailVC.h
//  feedEx
//
//  Created by csnguyen on 8/4/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEFlipFoodView.h"
@protocol FEFoodDetailVCDelegate <NSObject>
- (void)exitFoodDetailAtIndes:(NSUInteger)index;
@end

@interface FEFoodDetailVC : UIViewController
@property (weak, nonatomic) IBOutlet FEFlipFoodView *flipFoodView;
@property (nonatomic, weak) id<FEFoodDetailVCDelegate> delegate;
@end
