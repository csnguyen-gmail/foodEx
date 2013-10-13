//
//  FEPlaceEditMainVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceEditMainVC.h"
#import "FECoreDataController.h"
#import "Address.h"
#import "Photo.h"
#import "AbstractInfo+Extension.h"
#import "Tag+Extension.h"
#import "CoredataCommon.h"
#import "FEFoodEditVC.h"
#import "Common.h"
#import "FEAppDelegate.h"
#import "ThumbnailPhoto.h"
#import "User+Extension.h"

@interface FEPlaceEditMainVC () <FEVerticalResizeControlDelegate,CLLocationManagerDelegate, UIAlertViewDelegate, FEPlaceEditTVCDelegate, GMSMapViewDelegate>{
    float _minResizableHeight;
    float _maxResizableHeight;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet FEVerticalResizeControllView *verticalResizeView;
@property (weak, nonatomic) FEPlaceEditTVC *editPlaceInfoTVC;
@property (weak, nonatomic) IBOutlet UIView *editPlaceInfoView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) FECoreDataController * coreData;
@property (strong, nonatomic) NSArray *tags; // of Tag
@end

@implementation FEPlaceEditMainVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    // map view
    self.mapView.layer.cornerRadius = 10;
    self.mapView.delegate = self;
    
    // edit place info view
    self.editPlaceInfoTVC.editPlaceTVCDelegate = self;
    // vertical resize controller view
    self.verticalResizeView.delegate = self;
    _minResizableHeight = [self.editPlaceInfoTVC.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].size.height - 1;
    _maxResizableHeight = self.editPlaceInfoView.frame.size.height;
    // load place
    [self loadPlace];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:)
                                                 name:LOCATION_UPDATED object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_UPDATED object:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"foods"]) {
        FEFoodEditVC *foodEditVC = [segue destinationViewController];
        foodEditVC.place = self.placeInfo;
    }
    else if ([[segue identifier] isEqualToString:@"placeEdit"]) {
        self.editPlaceInfoTVC = [segue destinationViewController];
    }
}
#pragma mark - getter setter
- (NSArray *)tags {
    if (!_tags) {
        _tags = [Tag fetchTagsByType:CD_TAG_PLACE];
        
    }
    return _tags;
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
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
- (void)loadPlace {
    if (self.placeInfo == nil) {
        self.title = @"Add Place";
        self.placeInfo =  [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.coreData.managedObjectContext];
        self.placeInfo.owner = [User getUser];
        self.editPlaceInfoTVC.deleteButton.enabled = NO;
        self.mapView.camera = [GMSCameraPosition cameraWithLatitude:HCM_LATITUDE
                                                          longitude:HCM_LONGTITUDE
                                                               zoom:GMAP_DEFAULT_ZOOM];
        // get location
        FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate updateLocation];
    }
    else {
        Place *placeInfo = self.placeInfo;
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
            [self addMarketAt:CLLocationCoordinate2DMake([placeInfo.address.lattittude floatValue], [placeInfo.address.longtitude floatValue])
                      snippet:placeInfo.address.address
                     mapMoved:YES];
        }
        else {
            self.mapView.camera = [GMSCameraPosition cameraWithLatitude:HCM_LATITUDE
                                                              longitude:HCM_LONGTITUDE
                                                                   zoom:GMAP_DEFAULT_ZOOM];
        }
        // photos
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        for (Photo *photo in placeInfo.photos) {
            [photos addObject:photo.thumbnailPhoto.image];
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
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
- (void)rollback {
    [self.indicatorView startAnimating];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self.coreData.managedObjectContext rollback];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.indicatorView stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
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

#pragma mark - FEPlaceEditTVCDelegate
- (void)addNewThumbnailImage:(UIImage *)thumbnailImage andOriginImage:(UIImage *)originImage {
    [self.placeInfo insertPhotoWithThumbnail:thumbnailImage andOriginImage:originImage atIndex:0];
}
- (void)removeImageAtIndex:(NSUInteger)index {
    [self.placeInfo removePhotoAtIndex:index];
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
                                                        message:@"Edit Place Confirmation"
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
    UIView *upperView = self.editPlaceInfoView;
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
        delta = self.editPlaceInfoView.frame.size.height - _maxResizableHeight;
    }
    else {
        delta = self.editPlaceInfoView.frame.size.height - _minResizableHeight;
    }
    
    [UIView animateWithDuration:.3f animations:^{
        [self verticalResizeControllerDidChanged:-delta];
    }];
    

}
#pragma mark - Map
- (void)locationChanged:(NSNotification *)info {
    CLLocation* location = [info userInfo][@"location"];
    CLLocationCoordinate2D location2d = {location.coordinate.latitude, location.coordinate.longitude};
    GMSMarker *marker = [self addMarketAt:location2d snippet:@"" mapMoved:YES];
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location.coordinate completionHandler:^(GMSReverseGeocodeResponse *resp, NSError *error) {
        if (resp.firstResult != nil) {
            marker.snippet = [NSString stringWithFormat:@"%@, %@", resp.firstResult.addressLine1, resp.firstResult.addressLine2];
            if (self.editPlaceInfoTVC.addressTextField.text.length == 0) {
                self.editPlaceInfoTVC.addressTextField.text = marker.snippet;
            }
        }
    }];
}
- (GMSMarker*)addMarketAt:(CLLocationCoordinate2D)location snippet:(NSString*)snippet mapMoved:(BOOL)mapMoved{
    if (mapMoved) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                                longitude:location.longitude
                                                                     zoom:GMAP_DEFAULT_ZOOM];
        self.mapView.camera = camera;
    }
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location;
    marker.snippet = snippet;
    marker.map = self.mapView;
    marker.draggable = YES;
    return marker;
}

#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:marker.position completionHandler:^(GMSReverseGeocodeResponse *resp, NSError *error) {
        if (resp.firstResult != nil) {
            NSString *snippet = [NSString stringWithFormat:@"%@, %@", resp.firstResult.addressLine1, resp.firstResult.addressLine2];
            self.editPlaceInfoTVC.addressTextField.text = snippet;
        }
    }];
}
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    // just add Marker in case there is no one added beforehand
    if (self.mapView.markers.count != 0) {
        return;
    }
    GMSMarker *marker = [self addMarketAt:coordinate snippet:@"" mapMoved:NO];
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse *resp, NSError *error) {
        if (resp.firstResult != nil) {
            marker.snippet = [NSString stringWithFormat:@"%@, %@", resp.firstResult.addressLine1, resp.firstResult.addressLine2];
            self.editPlaceInfoTVC.addressTextField.text = marker.snippet;
        }
    }];
}
@end
