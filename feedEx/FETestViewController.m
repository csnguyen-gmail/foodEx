//
//  FETestViewController.m
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETestViewController.h"

@interface FETestViewController ()

@end

@implementation FETestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setDynamicScrollView:nil];
    [self setTestWiggleView:nil];
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
    NSMutableArray *images = [NSMutableArray arrayWithArray:@[[UIImage imageNamed:@"a_t"],
                                                              [UIImage imageNamed:@"b_t"],
                                                              [UIImage imageNamed:@"c_t"],
                                                              [UIImage imageNamed:@"d_t"],
                                                              [UIImage imageNamed:@"e_t"]]];
    self.dynamicScrollView.images = images;
    self.testWiggleView.additionalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]];
    self.testWiggleView.delegate = self;
    [self.testWiggleView startWiggling];
}
- (void)tappedToAdditionalView:(FEWiggleImageView *)wiggleImageView {
    NSLog(@"dsfsdf");
}
- (IBAction)addTapped:(id)sender {
    [self.dynamicScrollView addImage:[UIImage imageNamed:@"e_t"] atIndex:0];
}
@end
