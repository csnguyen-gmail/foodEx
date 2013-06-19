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
#import "Photo.h"
#import "AbstractInfo+Extension.h"
#import "Tag+Extension.h"
#import "CoredataCommon.h"

@interface FEEditPlaceInfoMainVC (){
    float _minResizableHeight;
    float _maxResizableHeight;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) FECoreDataController * coreData;
@property (strong, nonatomic) Place *placeInfo;
@property (strong, nonatomic) NSArray *tags; // of Tag
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
    self.editPlaceInfoTVC.editPlaceTVCDelegate = self;
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

- (NSArray *)tags {
    if (!_tags) {
        _tags = [Tag fetchTagsByType:CD_TAG_PLACE
                             withMOM:self.coreData.managedObjectModel
                              andMOC:self.coreData.managedObjectContext];
        
    }
    return _tags;
}

- (Place *)placeInfo {
    if (!_placeInfo) {
        if (self.placeId) {
            _placeInfo = (Place*)[self.coreData.managedObjectContext existingObjectWithID:self.placeId error:nil];
            _placeId = [_placeInfo objectID];
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
    if (placeInfo.address == nil) {
        placeInfo.address = [NSEntityDescription insertNewObjectForEntityForName:@"Address" inManagedObjectContext:self.coreData.managedObjectContext];
    }
    placeInfo.address.address = self.editPlaceInfoTVC.addressTextField.text;
    GMSMarker *marker = [self.mapView.markers lastObject];
    placeInfo.address.longtitude = @(marker.position.longitude);
    placeInfo.address.lattittude = @(marker.position.latitude);
    placeInfo.rating = @(self.editPlaceInfoTVC.ratingView.rate);
    placeInfo.note = self.editPlaceInfoTVC.noteTextView.usingPlaceholder? @"": self.editPlaceInfoTVC.noteTextView.text;
    [placeInfo updateTagWithStringTags:[self.editPlaceInfoTVC.tagTextView buildTagArray]
                            andTagType:CD_TAG_PLACE
                                inTags:self.tags
                                 byMOC:self.coreData.managedObjectContext];
    [self.coreData saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
        [self.indicatorView stopAnimating];
        [self dismissModalViewControllerAnimated:YES];
    }];
}
- (void)loadPlace {
    Place *placeInfo = self.placeInfo;
    
    if (self.isNewPlace) {
        self.title = @"Add Place";
        self.editPlaceInfoTVC.deleteButton.enabled = NO;
        // get location
        [self addLocationObervation];
    }
    else {
        // common
        self.title = @"Edit Place";
        self.editPlaceInfoTVC.nameTextField.text = placeInfo.name;
        self.editPlaceInfoTVC.addressTextField.text = placeInfo.address.address;
        self.editPlaceInfoTVC.ratingView.rate = [placeInfo.rating floatValue];
        [self.editPlaceInfoTVC.tagTextView setInitialText:[self buildStringTagsOfPlace]];
        [self.editPlaceInfoTVC.noteTextView setInitialText:placeInfo.note];
        self.editPlaceInfoTVC.deleteButton.enabled = YES;
        [self.editPlaceInfoTVC.deleteButton addTarget:self
                                               action:@selector(confirmDelete)
                                     forControlEvents:UIControlEventTouchUpInside];
        // address
        if (![placeInfo.address.lattittude isEqual: @(0)] && ![placeInfo.address.longtitude isEqual: @(0)]) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[placeInfo.address.lattittude floatValue]
                                                              longitude:[placeInfo.address.longtitude floatValue]];
            [self addMarketAt:location snippet:placeInfo.address.address];
        }
        // photos
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        for (Photo *photo in placeInfo.photos) {
            [photos addObject:photo.thumbnailPhoto];
        }
        [self.editPlaceInfoTVC setupPhotoScrollViewWithArrayOfThumbnailImages:photos];
    }
    self.editPlaceInfoTVC.tags = [self buildListStringTags];
}
- (void)deletePlace {
    [self.indicatorView startAnimating];
    // TODO: clear tag also in case it number of owner is clear.
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

- (NSArray *)buildListStringTags {
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for (Tag *tag in self.tags) {
        [tags addObject:tag.label];
    }
    return tags;
}
- (NSString *)buildStringTagsOfPlace {
    NSMutableString *stringTags = [[NSMutableString alloc] init];
    for (Tag *tag in self.placeInfo.tags) {
        [stringTags appendFormat:@"%@, ",tag.label];
    }
    return stringTags;
}

#pragma mark - FEEditPlaceInfoTVCDelegate
- (void)addNewThumbnailImage:(UIImage *)thumbnailImage andOriginImage:(UIImage *)originImage {
    [self.placeInfo insertPhotoWithThumbnail:thumbnailImage andOriginImage:originImage atIndex:0];
}
- (void)removeImageAtIndex:(NSUInteger)index {
    Photo *photo = [self.placeInfo removePhotoAtIndex:index];
    [self.coreData.managedObjectContext deleteObject:photo];
}
- (void)imageMovedFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [self.placeInfo movePhotoFromIndex:fromIndex toIndex:toIndex];
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
#define GMAP_LOCATION_OBSERVE_KEY @"myLocation"
#define GMAP_DEFAULT_ZOOM 15
- (void)addLocationObervation {
    if (!self.mapView.myLocationEnabled) {
        self.mapView.myLocationEnabled = YES;
        [self.mapView addObserver:self forKeyPath:GMAP_LOCATION_OBSERVE_KEY options:NSKeyValueObservingOptionNew context: nil];
    }
}
- (void)removeLocationObservation {
    if (self.mapView.myLocationEnabled) {
        self.mapView.myLocationEnabled = NO;
        [self.mapView removeObserver:self forKeyPath:GMAP_LOCATION_OBSERVE_KEY];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self removeLocationObservation];
    if ([keyPath isEqualToString:GMAP_LOCATION_OBSERVE_KEY] && [object isKindOfClass:[GMSMapView class]])
    {
        CLLocation* location = self.mapView.myLocation;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                                longitude:location.coordinate.longitude
                                                                     zoom:GMAP_DEFAULT_ZOOM];
        self.mapView.camera = camera;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location.coordinate completionHandler:^(GMSReverseGeocodeResponse *resp, NSError *error) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            marker.map = self.mapView;
            if (resp.firstResult != nil) {
                marker.snippet = [NSString stringWithFormat:@"%@, %@", resp.firstResult.addressLine1, resp.firstResult.addressLine2];
                if ([self.editPlaceInfoTVC.addressTextField.text isEqualToString:@""]) {
                    self.editPlaceInfoTVC.addressTextField.text = marker.snippet;
                }
            }
        }];
    }
}
- (void)addMarketAt:(CLLocation*)location snippet:(NSString*)snippet {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                            longitude:location.coordinate.longitude
                                                                 zoom:GMAP_DEFAULT_ZOOM];
    self.mapView.camera = camera;
    // TODO: draggable marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    marker.map = self.mapView;
    marker.snippet = snippet;
}

- (void)dealloc {
    [self removeLocationObservation];
}
@end
