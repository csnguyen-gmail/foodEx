//
//  FEUserInfoTVC.h
//  feedEx
//
//  Created by csnguyen on 9/19/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEUserInfoTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (strong, nonatomic) UIImage *originImage;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (nonatomic) BOOL textChanged;
@property (nonatomic) BOOL imageChanged;

@end
