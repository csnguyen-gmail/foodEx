//
//  FEEditPlaceInfoMainVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoMainVC.h"
#import "FECoreDataController.h"
#import "Address.h"

@interface FEEditPlaceInfoMainVC (){
    float _minResizableHeight;
    float _maxResizableHeight;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) FECoreDataController * coreData;
@property (strong, nonatomic) Place *placeInfo;
@property (assign, nonatomic) BOOL isNewPlace;
@end

@implementation FEEditPlaceInfoMainVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    // map view
    self.mapView.layer.cornerRadius = 10;
    
    // edit place info view
    self.editPlaceInfoTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPlaceInfoTVC"];
    self.editPlaceInfoTVC.tableView.layer.cornerRadius = 10;
    float tableHeight = [self.editPlaceInfoTVC.tableView rectForSection:0].size.height; // for remove last separate line
    self.editPlaceInfoTVC.tableView.frame = CGRectMake(0, 0,
                                                       self.scrollView.bounds.size.width,
                                                       tableHeight);
    [self addChildViewController:self.editPlaceInfoTVC];
    self.scrollView.layer.cornerRadius = 10;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, tableHeight - 1);
    [self.scrollView addSubview:self.editPlaceInfoTVC.tableView];
    self.scrollView.autoresizesSubviews = NO;
    // vertical resize controller view
    self.verticalResizeView.delegate = self;
    _minResizableHeight = [self.editPlaceInfoTVC.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].size.height - 1;
    _maxResizableHeight = self.scrollView.frame.size.height;
    
    // load place
    [self loadPlace];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setScrollView:nil];
    [self setVerticalResizeView:nil];
    [self setIndicatorView:nil];
    [super viewDidUnload];
}
#pragma mark - getter setter
- (void)setPlaceId:(NSManagedObjectID *)placeId {
    _placeId = placeId;
    self.isNewPlace = (placeId == nil);
}
- (void)setIsNewPlace:(BOOL)isNewPlace {
    _isNewPlace = isNewPlace;
    if (isNewPlace) {
        self.title = @"Add Place";
        // get location
        self.mapView.myLocationEnabled = YES;
        [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
    }
    else {
        self.title = @"Edit Place";
        
    }
}
- (Place *)placeInfo {
    if (!_placeInfo) {
        if (self.placeId) {
            _placeInfo = (Place*)[self.coreData.managedObjectContext existingObjectWithID:self.placeId error:nil];
        }
        else {
            _placeInfo = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.coreData.managedObjectContext];
        }
    }
    return _placeInfo;
}
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
#pragma mark - Coredata
- (void)savePlace {
    [self.indicatorView startAnimating];
    Place *placeInfo = self.placeInfo;
    placeInfo.name = self.editPlaceInfoTVC.nameTextField.text;
    placeInfo.address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:self.coreData.managedObjectContext];
    placeInfo.address.address = self.editPlaceInfoTVC.addressTextField.text;
    [self.coreData saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
        [self.indicatorView stopAnimating];
        [self dismissModalViewControllerAnimated:YES];
    }];
}
- (void)loadPlace {
    Place *placeInfo = self.placeInfo;
    self.editPlaceInfoTVC.nameTextField.text = placeInfo.name;
    self.editPlaceInfoTVC.addressTextField.text = placeInfo.address.address;
    self.editPlaceInfoTVC.deleteButton.enabled = !self.isNewPlace;
    [self.editPlaceInfoTVC.deleteButton addTarget:self
                                           action:@selector(confirmDelete)
                                 forControlEvents:UIControlEventTouchUpInside];
}
- (void)deletePlace {
    [self.indicatorView startAnimating];
    [self.coreData.managedObjectContext deleteObject:self.placeInfo];
    [self.navigationController popViewControllerAnimated:YES];
    [self.coreData saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
        [self.indicatorView stopAnimating];
        [self dismissModalViewControllerAnimated:YES];
    }];
}
- (void)rollback {
    [self.coreData.managedObjectContext rollback];
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - Alert view
#define ALERT_TAG_DELETE    1001
#define ALERT_TAG_DONE      1002
- (void)confirmDelete {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Delete Place Confirmation"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete & Exit", nil];
    alertView.tag = ALERT_TAG_DELETE;
    [alertView show];
}
- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Exit Place Confirmation"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save & Exit", @"Exit", nil];
    alertView.tag = ALERT_TAG_DONE;
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERT_TAG_DELETE) {
        switch (buttonIndex) {
            case 1:
                [self deletePlace];
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == ALERT_TAG_DONE) {
        switch (buttonIndex) {
            case 1:
                [self savePlace];
                break;
            case 2:
                [self rollback];
                break;
            default:
                break;
        }
    }
}

#pragma mark - FEVerticalResizeControlDelegate
- (void)verticalResizeControllerDidChanged:(float)delta {
    UIView *lowerView = self.mapView;
    UIView *upperView = self.scrollView;
    UIView *verticalControllerView = self.verticalResizeView;
    if (delta == .0f) {
        return;
    }
    if ((upperView.frame.size.height + delta) > _maxResizableHeight) {
        if (upperView.frame.size.height == _maxResizableHeight) {
            return;
        }
        delta = _maxResizableHeight - upperView.frame.size.height;
    }
    if ((upperView.frame.size.height + delta) < _minResizableHeight) {
        if (upperView.frame.size.height == _minResizableHeight) {
            return;
        }
        delta = _minResizableHeight - upperView.frame.size.height;
    }
    verticalControllerView.frame = CGRectMake(verticalControllerView.frame.origin.x,
                                              verticalControllerView.frame.origin.y + delta,
                                              verticalControllerView.frame.size.width,
                                              verticalControllerView.frame.size.height);
    lowerView.frame = CGRectMake(lowerView.frame.origin.x,
                                 lowerView.frame.origin.y + delta,
                                 lowerView.frame.size.width,
                                 lowerView.frame.size.height - delta);
    upperView.frame = CGRectMake(upperView.frame.origin.x,
                                 upperView.frame.origin.y,
                                 upperView.frame.size.width,
                                 upperView.frame.size.height + delta);
}

- (void)verticalResizeControllerDidTapped {
    float delta;
    if (self.verticalResizeView.frame.origin.y < self.view.frame.size.height / 2) {
        delta = self.scrollView.frame.size.height - _maxResizableHeight;
    }
    else {
        delta = self.scrollView.frame.size.height - _minResizableHeight;
    }
    
    [UIView animateWithDuration:.3f animations:^{
        [self verticalResizeControllerDidChanged:-delta];
    }];
    

}
#pragma mark - Map
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.mapView removeObserver:self forKeyPath:@"myLocation"];
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        CLLocation* location = self.mapView.myLocation;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                                longitude:location.coordinate.longitude
                                                                     zoom:15];
        self.mapView.camera = camera;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location.coordinate completionHandler:^(GMSReverseGeocodeResponse *resp, NSError *error) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            marker.map = self.mapView;
            if (resp.firstResult != nil) {
                marker.title = resp.firstResult.addressLine1;
                marker.snippet = resp.firstResult.addressLine2;
                if ([self.editPlaceInfoTVC.addressTextField.text isEqualToString:@""]) {
                    self.editPlaceInfoTVC.addressTextField.text = [NSString stringWithFormat:@"%@, %@", resp.firstResult.addressLine1, resp.firstResult.addressLine2];
                }
            }
        }];
        self.mapView.myLocationEnabled = NO;
    }
}
@end
