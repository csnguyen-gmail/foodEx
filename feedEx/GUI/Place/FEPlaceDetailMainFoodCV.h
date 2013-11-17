//
//  FEPlaceDetailMainFoodCV.h
//  feedEx
//
//  Created by csnguyen on 11/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FEPlaceDetailMainFoodCVDelegate<NSObject>
- (void)touchBegin;
- (void)touchEnd;
@end
@interface FEPlaceDetailMainFoodCV : UICollectionView
@property (nonatomic, weak) id <FEPlaceDetailMainFoodCVDelegate> touchDelegate;
@end
