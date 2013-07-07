//
//  FEFlipPhotosView.h
//  feedEx
//
//  Created by csnguyen on 7/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFlipListView.h"
@protocol FEFlipPhotosViewDelegate<NSObject>
- (void)didChangeCurrentIndex:(NSUInteger)index atRow:(NSUInteger)row;
@end

@interface FEFlipPhotosView : FEFlipListView
@property (nonatomic) BOOL usingThumbnail;
@property (nonatomic) NSUInteger rowIndex;
@property (nonatomic, weak) id<FEFlipPhotosViewDelegate> delegate;
@end
