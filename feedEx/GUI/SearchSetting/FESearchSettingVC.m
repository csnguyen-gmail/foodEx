//
//  FESearchSettingVC.m
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchSettingVC.h"
#import "FESearchPlaceSettingTVC.h"
#import "FESearchFoodSettingTVC.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

#define TOP_PADDING -22
@interface FESearchSettingVC ()

@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (strong, nonatomic) FESearchPlaceSettingTVC *placeSettingTVC;
@property (strong, nonatomic) FESearchFoodSettingTVC *foodSettingTVC;
@property (nonatomic) BOOL isPlace;
@end

@implementation FESearchSettingVC

- (void)viewDidLoad {
    self.placeSettingTVC = [self.storyboard instantiateViewControllerWithIdentifier:[[FESearchPlaceSettingTVC class] description]];
    self.foodSettingTVC = [self.storyboard instantiateViewControllerWithIdentifier:[[FESearchFoodSettingTVC class] description]];
    self.placeSettingTVC.view.frame = CGRectOffset(self.placeSettingTVC.view.frame, 0, TOP_PADDING);
    self.foodSettingTVC.view.frame = CGRectOffset(self.foodSettingTVC.view.frame, 0, TOP_PADDING);
    [self addChildViewController:self.placeSettingTVC];
    [self addChildViewController:self.foodSettingTVC];
    [self.panelView addSubview:self.placeSettingTVC.view];
    [self.panelView addSubview:self.foodSettingTVC.view];
    self.foodSettingTVC.view.hidden = YES;
    self.isPlace = YES;
}

- (IBAction)segmentChange:(UISegmentedControl *)sender {
    self.isPlace = (sender.selectedSegmentIndex == 0);
    [UIView transitionWithView:self.panelView
                      duration:0.5
                       options:(self.isPlace?UIViewAnimationOptionTransitionFlipFromRight:UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        self.foodSettingTVC.view.hidden = !self.foodSettingTVC.view.hidden;
                        self.placeSettingTVC.view.hidden = !self.placeSettingTVC.view.hidden;
                    }     
                    completion:^(BOOL finished) {
                    }];
}
- (void)viewDidUnload {
    [self setPanelView:nil];
    [super viewDidUnload];
}
@end
