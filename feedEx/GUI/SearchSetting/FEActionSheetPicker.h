//
//  FEAsctionSheetPicker.h
//  feedEx
//
//  Created by csnguyen on 6/23/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "AbstractActionSheetPicker.h"

@interface FEActionSheetPickerElement : NSObject
@property (nonatomic) NSUInteger selectedId;
@property (nonatomic) CGFloat width;
@property (nonatomic, strong) NSArray *rows; // of NSString
- (id)initWithSelectedId:(NSUInteger)selectedId width:(CGFloat)width rows:(NSArray *)rows;
@end

@class FEActionSheetPicker;
@protocol FEActionSheetPickerDelegate <NSObject>
- (void)didSelectPicker:(FEActionSheetPicker*)asp;
- (void)didCancelPicker:(FEActionSheetPicker*)asp;
@end
@interface FEActionSheetPicker : AbstractActionSheetPicker<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic) NSUInteger tag;
@property (nonatomic, weak) id<FEActionSheetPickerDelegate> delegate;
@property (nonatomic, strong) NSArray *columns; // of FEActionSheetPickerElement
- (id)initWithTitle:(NSString*)title columns:(NSArray*)columns delegate:(id<FEActionSheetPickerDelegate>)delegate origin:(id)origin;
- (void)showActionSheetPicker;
@end
