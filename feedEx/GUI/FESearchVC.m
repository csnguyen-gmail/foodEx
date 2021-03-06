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
#import "Food.h"
#import "UIAlertView+Extension.h"
#import "User+Extension.h"
#import <CoreLocation/CoreLocation.h>
#import "FEAppDelegate.h"

#define ALERT_DELETE_CONFIRM 0
@interface FESearchVC()<FESearchSettingVCDelegate, FEPlaceListTVCDelegate, FEFoodGridTVCDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) FESearchSettingInfo *searchSettingInfo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dispTypeSC;
@property (strong, nonatomic) UIBarButtonItem *editBtn;
@property (strong, nonatomic) UIBarButtonItem *searchBtn;
@property (strong, nonatomic) UIBarButtonItem *shareBtn;
@property (strong, nonatomic) UIBarButtonItem *deleteBtn;
@property (strong, nonatomic) UIBarButtonItem *selectAllBtn;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (nonatomic) BOOL isEditMode;
@property (nonatomic) BOOL isSelectAll;
@property (nonatomic) NSUInteger displayType; // Place or Food
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) FEPlaceListTVC *placeListTVC;
@property (weak, nonatomic) FEFoodGridCVC *foodGridCVC;
@property (weak, nonatomic) IBOutlet UIView *placeListView;
@property (weak, nonatomic) IBOutlet UIView *foodGridView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic) BOOL isGUISetup;
@property (weak, nonatomic) IBOutlet UIToolbar *quickSearchBar;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@end

@implementation FESearchVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    // fix IOS7 bug, Navigation bar transparent as default
    self.navigationController.navigationBar.translucent = NO;
    
    self.isGUISetup = NO;
    self.isEditMode = NO;
    // perpare GUI
    self.placeListTVC.placeListDelegate = self;
    self.foodGridCVC.foodGridDelegate = self;
    // navigation bar
    self.editBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain
                                                   target:self action:@selector(editAction:)];
    self.searchBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                   target:self action:@selector(searchAction:)];
    self.navigationItem.rightBarButtonItems = @[self.searchBtn, self.editBtn];
    // tool bar
    self.toolBar = [[UIToolbar alloc] init];
    self.toolBar.translucent = YES;
    self.toolBar.barStyle = UIBarStyleBlack;
    self.shareBtn = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered
                                                    target:self action:@selector(shareAction:)];
    self.selectAllBtn = [[UIBarButtonItem alloc] initWithTitle:@"Select all" style:UIBarButtonItemStyleBordered
                                                    target:self action:@selector(selectAllAction:)];
    self.deleteBtn = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered
                                                     target:self action:@selector(deleteAction:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil action:nil];

    self.deleteBtn.tintColor = [UIColor redColor];
    self.toolBar.items = @[self.deleteBtn, space, self.selectAllBtn, space, self.shareBtn];
    [self.view addSubview:self.toolBar];
    
    // load data
    [self refetchData];
    [self loadFollowDisplayType];
    // core data changed tracking register
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coredateChanged:)
                                                 name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:)
                                                 name:LOCATION_UPDATED object:nil];
}
- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_UPDATED object:nil];
}
- (void)dealloc {
    [self removeObserver];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        [self removeObserver];
        self.view = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isGUISetup == NO) {
        self.isGUISetup = YES;
        self.toolBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44);
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchTextField resignFirstResponder];
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
    CLLocation* location = [info userInfo][@"location"];
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
- (void)showQuickSearchBar {
    if (self.quickSearchBar.frame.origin.y == 0) {
        return;
    }
    // set current searching text
    if (self.displayType == SEARCH_DISPLAY_PLACE_TYPE) {
        self.searchTextField.text = self.placeListTVC.quickSearchString;
    }
    else {
        self.searchTextField.text = self.foodGridCVC.quickSearchString;
    }
    [UIView animateWithDuration:0.2 animations:^{
        // pull search bar down
        CGRect rect = self.quickSearchBar.frame;
        rect.origin.y = 0;
        self.quickSearchBar.frame = rect;
        // reduce content view;
        rect = self.mainView.frame;
        rect.origin.y += 44;
        self.mainView.frame = rect;
        // set focus
        [self.searchTextField becomeFirstResponder];
    }];
}
- (void)hideQuickSearchBar {
    [UIView animateWithDuration:0.2 animations:^{
        // pull search bar down
        CGRect rect = self.quickSearchBar.frame;
        rect.origin.y = -44;
        self.quickSearchBar.frame = rect;
        // reduce content view;
        rect = self.mainView.frame;
        rect.origin.y -= 44;
        self.mainView.frame = rect;
    }];
}
#pragma mark - action handler
- (IBAction)showTypeChange:(UISegmentedControl *)sender {
    self.displayType = sender.selectedSegmentIndex;
    [self switchDisplayFollowType:sender.selectedSegmentIndex withAnimation:YES];
    [self.searchTextField resignFirstResponder];
}
- (void)searchAction:(UIBarButtonItem *)sender {
    [self showQuickSearchBar];
}
- (IBAction)advanceSearchAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"searchSettingVC" sender:self];
}
- (void)editAction:(UIBarButtonItem *)sender {
    self.isEditMode = !self.isEditMode;
    self.isSelectAll = NO;
    [self animateToolBar];
    self.shareBtn.enabled = NO;
    self.deleteBtn.enabled = NO;
}
- (void)selectAllAction:(UIBarButtonItem *)sender {
    self.isSelectAll = !self.isSelectAll;
    if (self.displayType == SEARCH_DISPLAY_PLACE_TYPE) {
        [self.placeListTVC setSelectAll:self.isSelectAll];
    }
    else {
        [self.foodGridCVC setSelectAll:self.isSelectAll];
    }
}
- (void)shareAction:(UIBarButtonItem *)sender {
    [self.indicatorView startAnimating];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSArray *selectedPlaces = [self.placeListTVC getSelectedPlaces];
        User *user = [User getUser];
        NSDictionary *placeInfo = @{USER_KEY:user, PLACES_KEY:selectedPlaces};
        NSData *sendingData = [FEDataSerialize serializeMailData:placeInfo];
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"feedex.dat"];
//        [sendingData writeToFile:path atomically:YES];
        
        
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
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.indicatorView stopAnimating];
            [self presentViewController:picker animated:YES completion:nil];
            self.isEditMode = !self.isEditMode;
            [self animateToolBar];
        }];
    }];
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
- (void)queryWithQuickSearchString:(NSString*)searchString {
    if (self.displayType == SEARCH_DISPLAY_PLACE_TYPE) {
        [self.placeListTVC setQuickSearchString:searchString withAnimated:YES];
    }
    else {
        [self.foodGridCVC setQuickSearchString:searchString withAnimated:YES];
    }
}
#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    FEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate stopObservingFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self queryWithQuickSearchString:nil];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *searchString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self queryWithQuickSearchString:searchString];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    FEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate startObservingFirstResponder];
    [self hideQuickSearchBar];
}
- (void)animateToolBar {
    [UIView animateWithDuration:YES ? 0.2f :0.0f
                     animations:^{
                         self.searchBtn.enabled = !self.isEditMode;
                         self.dispTypeSC.enabled = !self.isEditMode;
                         self.dispTypeSC.userInteractionEnabled = !self.isEditMode;
                         self.editBtn.title = self.isEditMode ? @"Done" : @"Edit";
                         CGFloat delta = (self.isEditMode ? -1 : 1) * self.toolBar.frame.size.height;
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
                     }
                     completion:^(BOOL finished) {
                     }];
}
#pragma mark - setter getter
- (void)setIsEditMode:(BOOL)isEditMode {
    _isEditMode = isEditMode;
    if (self.displayType == SEARCH_DISPLAY_PLACE_TYPE) {
        self.placeListTVC.isEditMode = isEditMode;
    }
    else {
        self.foodGridCVC.isEditMode = isEditMode;
    }
}
- (void)setIsSelectAll:(BOOL)isSelectAll {
    _isSelectAll = isSelectAll;
    self.selectAllBtn.title = isSelectAll ? @"De-select all" : @"Select all";
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
#pragma mark - FEPlaceListTVCDelegate
- (void)didSelectPlaceRow {
    BOOL selected = [[self.placeListTVC.tableView indexPathsForSelectedRows] count] != 0;
    self.shareBtn.enabled = selected;
    self.deleteBtn.enabled = selected;
}

#pragma mark - FEFoodGridTVCDelegate
-(void)didSelectFoodItem {
    BOOL selected = [[self.foodGridCVC getSelectedFoods] count] != 0;
    self.deleteBtn.enabled = selected;
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
                if (self.displayType == SEARCH_DISPLAY_PLACE_TYPE) {
                    NSArray *selectedPlaces = [self.placeListTVC getSelectedPlaces];
                    for (Place *place in selectedPlaces) {
                        [coreData.managedObjectContext deleteObject:place];
                    }
                }
                else {
                    NSArray *selectedFoods = [self.foodGridCVC getSelectedFoods];
                    for (Food *food in selectedFoods) {
                        [coreData.managedObjectContext deleteObject:food];
                    }
                }
                [coreData saveToPersistenceStoreAndWait];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.indicatorView stopAnimating];
                }];
            }];
        }
    }    
}
@end
