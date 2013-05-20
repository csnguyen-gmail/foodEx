//
//  FETestViewController.h
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEDynamicScrollView.h"
@interface FETestViewController : UIViewController
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *dynamicScrollView;
- (IBAction)addTapped:(id)sender;
- (IBAction)endEdit:(id)sender;

@end
