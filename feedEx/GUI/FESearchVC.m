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
#import "FEDataSerialize.h"
#import <MessageUI/MessageUI.h>
#import "FECoreDataController.h"
#import "Common.h"
#import "Place.h"
#import "UIAlertView+Extension.h"

#define PLACE_DISP_TYPE @"PlaceDispType"
#define LIST_TYPE 0
#define GRID_TYPE 1

#define ALERT_DELETE_CONFIRM 0
#define ALERT_DELETING 1
@interface FESearchVC()<FESearchSettingVCDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) FESearchSettingInfo *searchSettingInfo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dispTypeSC;
@property (strong, nonatomic) UIBarButtonItem *editBtn;
@property (strong, nonatomic) UIBarButtonItem *searchBtn;
@property (strong, nonatomic) UIBarButtonItem *shareBtn;
@property (strong, nonatomic) UIBarButtonItem *deleteBtn;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (nonatomic) BOOL isEditMode;
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
    // tracking Coredata change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];

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
    [self.placeDataSource queryPlaceInfoWithSetting:self.searchSettingInfo.placeSetting];
    [self loadPlaceDisplayType];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:nil];
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
- (void)handleDataModelChange:(NSNotification *)note {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self refetchData];
    }];
}
- (void)refetchData {
    [self.placeDataSource queryPlaceInfoWithSetting:self.searchSettingInfo.placeSetting];
    [self updatePlaceDateSourceWithType:self.placeDispType];
    // TODO: update location only in case User refresh
    [self.placeDataSource updateLocation:^(CLLocation *location) {
        if (self.placeDispType == LIST_TYPE) {
            [self.placeListTVC.tableView reloadData];
        }
        else {
            [self.placeGridCVC.collectionView reloadData];
        }
    }];
}
#pragma mark - utility
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
    self.isEditMode = !self.isEditMode;
}
- (void)shareAction:(UIBarButtonItem *)sender {
    NSArray *selectedPlaces = [self getSelectedPlaces];
    // TODO: User
    NSDictionary *placeInfo = @{PLACES_KEY:selectedPlaces};
    NSData *sendingData = [FEDataSerialize serializePlaces:placeInfo];
    
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
                         CGRect gridRect = self.placeGridCVC.view.frame;
                         gridRect.size.height += delta;
                         self.placeGridCVC.view.frame = gridRect;
                         // adjust toolbar y
                         CGRect toolbarRect = self.toolBar.frame;
                         toolbarRect.origin.y += delta;
                         self.toolBar.frame = toolbarRect;
                         if (self.placeDispType == LIST_TYPE) {
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
    if (self.placeDispType == LIST_TYPE) {
        NSArray *selectedRows = [self.placeListTVC.tableView indexPathsForSelectedRows];
        for (NSIndexPath *index in selectedRows) {
            [selectedPlaces addObject:self.placeDataSource.places[index.row]];
        }
    }
    else {
        // TODO
    }
    return selectedPlaces;
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
            // show loading alert
            UIAlertView *processingAlertView = [UIAlertView indicatorAlertWithTitle:nil
                                                                            message:@"Deleting data out of database..."
                                                                           delegate:nil];
            processingAlertView.tag = ALERT_DELETING;
            [processingAlertView show];
            // start thread
            NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
            [operationQueue addOperationWithBlock:^{
                FECoreDataController *coreData = [FECoreDataController sharedInstance];
                NSArray *selectedPlaces = [self getSelectedPlaces];
                for (Place *place in selectedPlaces) {
                    [coreData.managedObjectContext deleteObject:place];
                }
                [coreData saveToPersistenceStoreAndWait];
                [processingAlertView dismissWithClickedButtonIndex:0 animated:NO];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.isEditMode = !self.isEditMode;
                }];
            }];
        }
        else {
            
        }
    }
    else {
        
    }
    
}
@end
