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

@interface FEEditPlaceInfoTVC : UITableViewController<FEDynamicScrollViewDelegate, UITextFieldDelegate, GKImagePickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@end
