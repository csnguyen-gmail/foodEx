//
//  FEImagePickerGridView.h
//  NewImagePicker
//
//  Created by csnguyen on 11/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FEImagePickerGridViewDelegate <NSObject>
- (void)tapAtPoint:(CGPoint)point;
@end

@interface FEImagePickerGridView : UIView
@property (nonatomic) NSUInteger numberOfLine;
@property (nonatomic) BOOL hiddenGrid;
@property (weak, nonatomic) id<FEImagePickerGridViewDelegate> delegate;
@end
