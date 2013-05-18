//
//  FETestViewController.h
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FEDynamicScrollView.h"
@interface FETestViewController : UIViewController <FEWiggleImageViewProtocol>
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *dynamicScrollView;
@property (weak, nonatomic) IBOutlet FEWiggleImageView *testWiggleView;
- (IBAction)addTapped:(id)sender;

@end
