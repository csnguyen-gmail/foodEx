//
//  FEAsctionSheetPicker.m
//  feedEx
//
//  Created by csnguyen on 6/23/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEActionSheetPicker.h"
@implementation FEActionSheetPickerElement
- (id)initWithSelectedId:(NSUInteger)selectedId width:(CGFloat)width rows:(NSArray *)rows {
    if (self = [super init]) {
        _selectedId = selectedId;
        _width = width;
        _rows = rows;
    }
    return self;
}
@end

@implementation FEActionSheetPicker
- (id)initWithTitle:(NSString*)title columns:(NSArray*)columns delegate:(id<FEActionSheetPickerDelegate>)delegate origin:(id)origin {
    if (self = [super initWithTarget:nil successAction:nil cancelAction:nil origin:origin]) {
        _columns = columns;
        _delegate = delegate;
        self.title = title;
    }
    return self;
}
- (void)showActionSheetPicker {
    [super showActionSheetPicker];
    // set selected index
    for (int i = 0; i < self.columns.count; i++) {
        [self.pickerView selectRow:[self.columns[i] selectedId] inComponent:i animated:NO];
    }
}
#pragma mark - AbstractActionSheetPicker fulfilment
- (UIView *)configuredPickerView {
    CGRect pickerFrame = CGRectMake(0, 40, self.viewSize.width, 216);
    UIPickerView *pv = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pv.delegate = self;
    pv.dataSource = self;
    pv.showsSelectionIndicator = YES;
    return pv;
}
- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction origin:(id)origin
{
    if ([self.delegate respondsToSelector:@selector(didSelectPicker:)]) {
        // update selected index
        for (int i = 0; i < self.columns.count; i++) {
            [self.columns[i] setSelectedId:[self.pickerView selectedRowInComponent:i]];
        }
        [self.delegate didSelectPicker:self];
    }
}
- (void)notifyTarget:(id)target didCancelWithAction:(SEL)cancelAction origin:(id)origin
{
    if ([self.delegate respondsToSelector:@selector(didCancelPicker::)]) {
        [self.delegate didCancelPicker:self];
    }
}

#pragma mark - UIPickerViewDataSource Implementation
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.columns.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.columns[component] rows].count;
}
#pragma mark UIPickerViewDelegate Implementation
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return [self.columns[component] width];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.columns[component] rows][row];
}
@end
