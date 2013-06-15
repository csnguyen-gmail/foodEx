//
//  FEEditPlaceInfoTVC.h
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEDynamicScrollView.h"
#import "GKImagePicker.h"
#import "FETagTextView.h"
#import "CPTextViewPlaceholder.h"

@interface FEEditPlaceInfoTVC : UITableViewController<FEDynamicScrollViewDelegate, UITextFieldDelegate, GKImagePickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet FETagTextView *tagTextView;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *noteTextView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) NSArray *tags; // array of NSString

@end
