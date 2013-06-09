//
//  FETagTextField.h
//  feedEx
//
//  Created by csnguyen on 6/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FECustomInputAccessoryView.h"

@interface FETagTextField : UITextField<FECustomInputAccessoryViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, weak) UIResponder *nextTextField;
@end
