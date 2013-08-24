//
//  FESearchVC.m
//  feedEx
//
//  Created by csnguyen on 6/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchVC.h"
#import "FEPlaceListTVC.h"
#import "FEPlaceGridCVC.h"
#import "FESearchSettingInfo.h"
#import "FESearchSettingVC.h"
#import "FEPlaceDataSource.h"

#define PLACE_DISP_TYPE @"PlaceDispType"
@interface FESearchVC()<FESearchSettingVCDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) FESearchSettingInfo *searchSettingInfo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dispTypeSC;
@property (nonatomic) NSUInteger placeDispType; // List or Grid
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) FEPlaceListTVC *placeListTVC;
@property (weak, nonatomic) FEPlaceGridCVC *placeGridCVC;
@property (weak, nonatomic) IBOutlet UIView *placeListView;
@property (weak, nonatomic) IBOutlet UIView *placeGridView;
@property (strong, nonatomic) FEPlaceDataSource *placeDataSource;
@end

@implementation FESearchVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.needUpdateDatabase = YES;
    
    // create a edit button
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain
                                                                                target:self action:@selector(editAction:)];
    // create a search button
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                  target:self action:@selector(searchAction:)];
    self.navigationItem.rightBarButtonItems = @[searchButton, editButton];
    
    [self.placeDataSource queryPlaceInfoWithSetting:self.searchSettingInfo.placeSetting];
    [self loadPlaceDisplayType];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.needUpdateDatabase) {
        self.needUpdateDatabase = NO;
        [self.placeDataSource queryPlaceInfoWithSetting:self.searchSettingInfo.placeSetting];
        [self updatePlaceDateSourceWithType:self.placeDispType];
        // TODO: update locatio only in case User refresh
        [self.placeDataSource updateLocation:^(CLLocation *location) {
            if (self.placeDispType == 0) {
                [self.placeListTVC.tableView reloadData];
            }
            else {
                [self.placeGridCVC.collectionView reloadData];
            }
        }];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)loadPlaceDisplayType {
    _placeDispType = [[NSUserDefaults standardUserDefaults] integerForKey:PLACE_DISP_TYPE];
    [self switchPlaceDispToType:self.placeDispType withAnimation:NO];
}
- (void)setPlaceDispType:(NSUInteger)placeDispType {
    _placeDispType = placeDispType;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:placeDispType forKey:PLACE_DISP_TYPE];
    [defaults synchronize];
}
- (void)switchPlaceDispToType:(NSUInteger)type withAnimation:(BOOL)animated{
    UIView *shownView = (type == 0) ? self.placeListView : self.placeGridView;
    UIView *hiddenView = (type == 0) ? self.placeGridView : self.placeListView;
    if (animated) {
        [UIView transitionWithView:self.mainView
                          duration:0.4
                           options:(type == 0) ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                        animations: ^{
                            shownView.hidden = NO;
                            hiddenView.hidden = YES;
                        }
                        completion:^(BOOL finished) {
                        }];
    }
    else {
        shownView.hidden = NO;
        hiddenView.hidden = YES;
    }
    self.dispTypeSC.selectedSegmentIndex = type;
    [self updatePlaceDateSourceWithType:type];
}
- (void)updatePlaceDateSourceWithType:(NSUInteger)type {
    if (type == 0) {
        self.placeListTVC.placeDataSource = self.placeDataSource;
        self.placeGridCVC.placeDataSource = nil;
    }
    else {
        self.placeListTVC.placeDataSource = nil;
        self.placeGridCVC.placeDataSource = self.placeDataSource;
    }
}
#pragma mark - action handler
- (IBAction)showTypeChange:(UISegmentedControl *)sender {
    self.placeDispType = sender.selectedSegmentIndex;
    [self switchPlaceDispToType:sender.selectedSegmentIndex withAnimation:YES];
}
- (void)searchAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"searchSettingVC" sender:self];
}
- (void)editAction:(UIBarButtonItem *)sender {
    // TODO
}

#pragma mark - getter setter
- (FESearchSettingInfo *)searchSettingInfo {
    if (!_searchSettingInfo) {
        NSData *archivedObject = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_SETTING_KEY];
        if (archivedObject) {
            _searchSettingInfo = (FESearchSettingInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
        }
        else {
            _searchSettingInfo = [[FESearchSettingInfo alloc] init];
            _searchSettingInfo.placeSetting = [[FESearchPlaceSettingInfo alloc] init];
            _searchSettingInfo.foodSetting = [[FESearchFoodSettingInfo alloc] init];
        }
        
    }
    return _searchSettingInfo;
}
- (FEPlaceDataSource *)placeDataSource {
    if (!_placeDataSource) {
        _placeDataSource = [[FEPlaceDataSource alloc] init];
    }
    return _placeDataSource;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeList"]) {
        self.placeListTVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"placeGrid"]) {
        self.placeGridCVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"searchSettingVC"]) {
        FESearchSettingVC *searchSettingVC = [segue destinationViewController];
        searchSettingVC.delegate = self;
    }
}
#pragma mark - FESearchSettingVCDelegate
- (void)didFinishSearchSetting:(FESearchSettingInfo *)searchSetting hasModification:(BOOL)hasModification {
    if (hasModification) {
        self.searchSettingInfo = searchSetting;
        self.needUpdateDatabase = YES;
    }
}
@end
