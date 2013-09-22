//
//  FEMapSearchSettingVC.m
//  feedEx
//
//  Created by csnguyen on 9/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEMapSearchSettingVC.h"
#import "DYRateView.h"
#import "FESearchTagVC.h"
#import "CoredataCommon.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

@interface FEMapSearchSettingVC ()
@property (weak, nonatomic) IBOutlet DYRateView *ratingView;
@property (weak, nonatomic) FESearchTagVC *searchTagVC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchBySC;
@property (strong, nonatomic) FEMapSearchPlaceSettingInfo *settingInfo;
@end

@implementation FEMapSearchSettingVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ratingView setupBigStarEditable:YES];
    self.searchTagVC.view.backgroundColor = [UIColor clearColor];
    self.searchTagVC.view.layer.cornerRadius = 10.0;
    self.searchTagVC.view.layer.masksToBounds = YES;
    self.searchTagVC.view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.searchTagVC.view.layer.borderWidth = 1.0;
    
    [self loadSetting];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveSetting];
    [self.delegate didFinishSetting:self.settingInfo hasModification:YES];// TODO
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"tagSelection"]) {
        self.searchTagVC = [segue destinationViewController];
    }
}
- (void)loadSetting {
    NSData *archivedObject = [[NSUserDefaults standardUserDefaults] objectForKey:MAP_SEARCH_SETTING_KEY];
    if (archivedObject) {
        self.settingInfo = (FEMapSearchPlaceSettingInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    }
    else {
        self.settingInfo = [[FEMapSearchPlaceSettingInfo alloc] init];
    }
    self.ratingView.rate = self.settingInfo.rating;
    self.searchBySC.selectedSegmentIndex = self.settingInfo.searchBy;
    [self.searchTagVC loadTagWithTagType:CD_TAG_PLACE andSelectedTags:[self.settingInfo.tags componentsSeparatedByString:SEPARATED_TAG_STR]];
}

- (void)saveSetting {
    self.settingInfo.rating = self.ratingView.rate;
    self.settingInfo.searchBy = self.searchBySC.selectedSegmentIndex;
    self.settingInfo.tags = [self.searchTagVC getSelectedTagsString];

    NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:self.settingInfo];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:archivedObject forKey:MAP_SEARCH_SETTING_KEY];
    [defaults synchronize];
}

@end
