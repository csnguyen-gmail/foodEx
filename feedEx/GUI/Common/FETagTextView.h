//
//  FETagTextField.h
//  feedEx
//
//  Created by csnguyen on 6/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FECustomInputAccessoryView.h"
#import "CPTextViewPlaceholder.h"

@interface FETagTextView : CPTextViewPlaceholder<FECustomInputAccessoryViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, weak) UIResponder *nextTextField;

- (NSMutableArray*)buildTagArray;
@end
