//
//  FESearchSettingVC.m
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <math.h>
#import "FESearchSettingVC.h"
#import "FESearchPlaceSettingTVC.h"
#import "FESearchFoodSettingTVC.h"


#define TOP_PADDING -22
@interface FESearchSettingVC ()

@property (weak, nonatomic) IBOutlet UIView *panelView;
@property (strong, nonatomic) FESearchPlaceSettingTVC *placeSettingTVC;
@property (strong, nonatomic) FESearchFoodSettingTVC *foodSettingTVC;
@property (weak, nonatomic) IBOutlet UIView *placeSettingView;
@property (weak, nonatomic) IBOutlet UIView *foodSettingView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *displayTypeSC;
@property (nonatomic, strong) FESearchSettingInfo *searchSettingInfo;
@end

@implementation FESearchSettingVC

- (void)viewDidLoad {
    [self loadSetting];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        // Back button on Navigation bar tapped
        [self saveSetting];
        [self.delegate didFinishSearchSetting:self.searchSettingInfo hasModification:YES];// TODO
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"searchFoodSetting"]) {
        self.foodSettingTVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"searchPlaceSetting"]) {
        self.placeSettingTVC = [segue destinationViewController];
    }
    
}
- (void)swicthToView:(NSUInteger)viewIndex wthAnimated:(BOOL)animated {
    UIView *backView = (viewIndex == 0) ? self.foodSettingView : self.placeSettingView;
    UIView *frontView = (viewIndex == 0) ? self.placeSettingView : self.foodSettingView;
    [UIView transitionWithView:self.panelView
                      duration:animated ? 0.5 : 0.0
                       options:(viewIndex == 0 ? UIViewAnimationOptionTransitionFlipFromRight:UIViewAnimationOptionTransitionFlipFromLeft)
                    animations: ^{
                        backView.hidden = YES;
                        frontView.hidden = NO;
                    }
                    completion:^(BOOL finished) {
                    }];
}
- (IBAction)segmentChange:(UISegmentedControl *)sender {
    [self swicthToView:sender.selectedSegmentIndex wthAnimated:YES];
}
- (void)loadSetting {
    NSData *archivedObject = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_SETTING_KEY];
    if (archivedObject) {
        self.searchSettingInfo = (FESearchSettingInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    }
    else {
        self.searchSettingInfo = [[FESearchSettingInfo alloc] init];
        self.searchSettingInfo.placeSetting = [[FESearchPlaceSettingInfo alloc] init];
        self.searchSettingInfo.foodSetting = [[FESearchFoodSettingInfo alloc] init];
    }
    // Place
    self.placeSettingTVC.nameTF.text = self.searchSettingInfo.placeSetting.name;
    self.placeSettingTVC.addressTF.text  = self.searchSettingInfo.placeSetting.address;
    self.placeSettingTVC.ratingView.rate = self.searchSettingInfo.placeSetting.rating;
    self.placeSettingTVC.tagsTF.text = self.searchSettingInfo.placeSetting.tags;
    [self.placeSettingTVC setFirstSortText:self.searchSettingInfo.placeSetting.firstSort
                         andSecondSortText:self.searchSettingInfo.placeSetting.secondSort];
    // Food
    self.foodSettingTVC.nameTF.text = self.searchSettingInfo.foodSetting.name;
    self.foodSettingTVC.tagsTF.text = self.searchSettingInfo.foodSetting.tags;
    self.foodSettingTVC.costExprTF.text  = self.searchSettingInfo.foodSetting.costExpression;
    self.foodSettingTVC.bestSC.selectedSegmentIndex = self.searchSettingInfo.foodSetting.bestType;
    [self.foodSettingTVC setFirstSortText:self.searchSettingInfo.foodSetting.firstSort
                        andSecondSortText:self.searchSettingInfo.foodSetting.secondSort];
    // Display type
    self.displayTypeSC.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:SEARCH_DISPLAY_TYPE_KEY];
    [self swicthToView:self.displayTypeSC.selectedSegmentIndex wthAnimated:NO];
}

- (void)saveSetting {
    // Place
    self.searchSettingInfo.placeSetting.name = self.placeSettingTVC.nameTF.text;
    self.searchSettingInfo.placeSetting.address = self.placeSettingTVC.addressTF.text;
    self.searchSettingInfo.placeSetting.rating = self.placeSettingTVC.ratingView.rate;
    self.searchSettingInfo.placeSetting.tags = self.placeSettingTVC.tagsTF.text;
    self.searchSettingInfo.placeSetting.firstSort = self.placeSettingTVC.firstSortTF.text;
    self.searchSettingInfo.placeSetting.secondSort = self.placeSettingTVC.secondSortTF.text;
    // Food
    self.searchSettingInfo.foodSetting.name = self.foodSettingTVC.nameTF.text;
    self.searchSettingInfo.foodSetting.tags = self.foodSettingTVC.tagsTF.text;
    self.searchSettingInfo.foodSetting.costExpression = self.foodSettingTVC.costExprTF.text;
    self.searchSettingInfo.foodSetting.bestType = self.foodSettingTVC.bestSC.selectedSegmentIndex;
    self.searchSettingInfo.foodSetting.firstSort = self.foodSettingTVC.firstSortTF.text;
    self.searchSettingInfo.foodSetting.secondSort = self.foodSettingTVC.secondSortTF.text;
    NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:self.searchSettingInfo];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:archivedObject forKey:SEARCH_SETTING_KEY];
    [defaults synchronize];
}
@end
