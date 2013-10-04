//
//  FESearchVC.m
//  feedEx
//
//  Created by csnguyen on 6/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchVC.h"
#import "FEPlaceListTVC.h"
#import "FEFoodGridCVC.h"
#import "FESearchSettingInfo.h"
#import "FESearchSettingVC.h"
#import "FEDataSerialize.h"
#import <MessageUI/MessageUI.h>
#import "FECoreDataController.h"
#import "Common.h"
#import "Place.h"
#import "UIAlertView+Extension.h"
#import "FEAppDelegate.h"
#import "User+Extension.h"

#define ALERT_DELETE_CONFIRM 0
@interface FESearchVC()<FESearchSettingVCDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) FESearchSettingInfo *searchSettingInfo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dispTypeSC;
@property (strong, nonatomic) UIBarButtonItem *editBtn;
@property (strong, nonatomic) UIBarButtonItem *searchBtn;
@property (strong, nonatomic) UIBarButtonItem *shareBtn;
@property (strong, nonatomic) UIBarButtonItem *deleteBtn;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (nonatomic) BOOL isEditMode;
@property (nonatomic) NSUInteger displayType; // Place or Food
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) FEPlaceListTVC *placeListTVC;
@property (weak, nonatomic) FEFoodGridCVC *foodGridCVC;
@property (weak, nonatomic) IBOutlet UIView *placeListView;
@property (weak, nonatomic) IBOutlet UIView *foodGridView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@end

@implementation FESearchVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    // perpare GUI
    // navigation bar
    self.editBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain
                                                   target:self action:@selector(editAction:)];
    self.searchBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                   target:self action:@selector(searchAction:)];
    self.navigationItem.rightBarButtonItems = @[self.editBtn, self.searchBtn];
    // tool bar
    self.toolBar = [[UIToolbar alloc] init];
    self.shareBtn = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered
                                                    target:self action:@selector(shareAction:)];
    self.deleteBtn = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered
                                                     target:self action:@selector(deleteAction:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];

    self.deleteBtn.tintColor = [UIColor redColor];
    self.toolBar.items = @[self.deleteBtn, space, self.shareBtn];
    [self.view addSubview:self.toolBar];
    
    // load data
    [self refetchData];
    [self loadFollowDisplayType];
    // core data changed tracking register
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coredateChanged:)
                                                 name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:)
                                                 name:LOCATION_UPDATED object:nil];
    // get location
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate updateLocation];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_UPDATED object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.toolBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44);
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isEditMode) {
        [self setIsEditMode:NO];
    }
}
#pragma mark - handler DataModel changed
- (void)coredateChanged:(NSNotification *)info {
    [self refetchData];
}
- (void)refetchData {
    [self.placeListTVC updatePlacesWithSettingInfo:self.searchSettingInfo.placeSetting];
    [self.foodGridCVC updateFoodsWithSettingInfo:self.searchSettingInfo.foodSetting];
}
#pragma mark - handle location change
- (void)locationChanged:(NSNotification*)info {
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CLLocation* location = [delegate getCurrentLocation];
    self.placeListTVC.currentLocation = location;
}
#pragma mark - utility
- (void)loadFollowDisplayType {
    _displayType = [[NSUserDefaults standardUserDefaults] integerForKey:SEARCH_DISPLAY_TYPE_KEY];
    [self switchDisplayFollowType:self.displayType withAnimation:NO];
}
- (void)setDisplayType:(NSUInteger)displayType {
    _displayType = displayType;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:displayType forKey:SEARCH_DISPLAY_TYPE_KEY];
    [defaults synchronize];
}
- (void)switchDisplayFollowType:(NSUInteger)type withAnimation:(BOOL)animated{
    UIView *shownView = (type == 0) ? self.placeListView : self.foodGridView;
    UIView *hiddenView = (type == 0) ? self.foodGridView : self.placeListView;
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
}
#pragma mark - action handler
- (IBAction)showTypeChange:(UISegmentedControl *)sender {
    self.displayType = sender.selectedSegmentIndex;
    [self switchDisplayFollowType:sender.selectedSegmentIndex withAnimation:YES];
}
- (void)searchAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"searchSettingVC" sender:self];
}
- (void)editAction:(UIBarButtonItem *)sender {
    self.isEditMode = !self.isEditMode;
}
- (void)shareAction:(UIBarButtonItem *)sender {
    NSArray *selectedPlaces = [self getSelectedPlaces];
    User *user = [User getUser];
    NSDictionary *placeInfo = @{USER_KEY:user, PLACES_KEY:selectedPlaces};
    NSData *sendingData = [FEDataSerialize serializeMailData:placeInfo];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ATTACHED_FILENAME_DATE_FORMAT;
    NSDate *now = [[NSDate alloc] init];
    NSString *filename = [NSString stringWithFormat:ATTACHED_FILENAME_FORMAT, [dateFormatter stringFromDate:now]];
    NSMutableString *body = [[NSMutableString alloc] initWithString:MAIL_BODY];
    for (Place *place in selectedPlaces) {
        [body appendString:[NSString stringWithFormat:@"+%@\n", place.name]];
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker setSubject:MAIL_SUBJECT];
    [picker addAttachmentData:sendingData mimeType:ATTACHED_FILETYPE fileName:filename];
    [picker setToRecipients:[NSArray array]];
    [picker setMessageBody:body isHTML:NO];
    [picker setMailComposeDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
    
    self.isEditMode = !self.isEditMode;
}
- (void)deleteAction:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Do you want to delete?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
    alertView.tag = ALERT_DELETE_CONFIRM;
    [alertView show];
}
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    [UIView animateWithDuration:YES ? 0.2f :0.0f
                     animations:^{
                         self.searchBtn.enabled = !isEditMode;
                         self.dispTypeSC.enabled = !isEditMode;
                         self.dispTypeSC.userInteractionEnabled = !isEditMode;
                         self.editBtn.title = isEditMode ? @"Done" : @"Edit";
                         CGFloat delta = (isEditMode ? -1 : 1) * self.toolBar.frame.size.height;
                         // adjust listView height
                         CGRect listRect = self.placeListTVC.view.frame;
                         listRect.size.height += delta;
                         self.placeListTVC.view.frame = listRect;
                         // adjust gridView height
                         CGRect gridRect = self.foodGridCVC.view.frame;
                         gridRect.size.height += delta;
                         self.foodGridCVC.view.frame = gridRect;
                         // adjust toolbar y
                         CGRect toolbarRect = self.toolBar.frame;
                         toolbarRect.origin.y += delta;
                         self.toolBar.frame = toolbarRect;
                         if (self.displayType == SEARCH_DISPLAY_PLACE_TYPE) {
                             self.placeListTVC.isEditMode = isEditMode;
                         }
                         else {
                             // TODO
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
    
}
- (NSArray*)getSelectedPlaces {
    NSMutableArray *selectedPlaces = [NSMutableArray array];
    if (self.displayType == SEARCH_DISPLAY_PLACE_TYPE) {
        NSArray *selectedRows = [self.placeListTVC.tableView indexPathsForSelectedRows];
        for (NSIndexPath *index in selectedRows) {
            [selectedPlaces addObject:self.placeListTVC.places[index.row]];
        }
    }
    else {
        // TODO
    }
    return selectedPlaces;
}

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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeList"]) {
        self.placeListTVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"placeGrid"]) {
        self.foodGridCVC = [segue destinationViewController];
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
        [self refetchData];
    }
}
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_DELETE_CONFIRM) {
        // YES button
        if (buttonIndex == 1) {
            [self.indicatorView startAnimating];
            // start thread
            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
            [operationQueue addOperationWithBlock:^{
                FECoreDataController *coreData = [FECoreDataController sharedInstance];
                NSArray *selectedPlaces = [self getSelectedPlaces];
                for (Place *place in selectedPlaces) {
                    [coreData.managedObjectContext deleteObject:place];
                }
                [coreData saveToPersistenceStoreAndWait];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.indicatorView stopAnimating];
                    self.isEditMode = !self.isEditMode;
                }];
            }];
        }
    }    
}
@end
