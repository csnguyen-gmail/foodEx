//
//  FEMapVC.m
//  feedEx
//
//  Created by csnguyen on 8/8/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEMapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Common.h"
#import "FECoreDataController.h"
#import "FEPlaceDataSource.h"
#import "Place+Extension.h"
#import "Address.h"
#import "FEMapUtility.h"
#import "FEPlaceListSearchMapTVC.h"
#import "FEAppDelegate.h"

@interface FEMapVC()<FEPlaceListSearchMapTVCDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (weak, nonatomic) FECoreDataController *coreData;
@property (strong, nonatomic) NSArray *places;
@property (nonatomic, strong) FESearchPlaceSettingInfo *searchPlaceSettingInfo;
@property (weak, nonatomic) IBOutlet UIToolbar *searchPlaceBar;
@property (weak, nonatomic) IBOutlet UIView *seacrhResultView;
@property (weak, nonatomic) FEPlaceListSearchMapTVC *placeListTVC;
@property (weak, nonatomic) GMSMarker *locationMarker;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) BOOL shouldFitMarkers;
@end

@implementation FEMapVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.settings.compassButton = YES;
    [self reloadDataSource];
    [self fitMarkerInBound];
    [self hideSearchResultWithAnimated:NO];
    self.placeListTVC.searchDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coredateChanged:)
                                                 name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:)
                                                 name:LOCATION_UPDATED object:nil];
    // get location
    [self updateLocationWithFitMarker:YES];
    [self.indicationView startAnimating];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_UPDATED object:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeList"]) {
        self.placeListTVC = [segue destinationViewController];
    }
}

- (void)updateLocationWithFitMarker:(BOOL)fitMarkers {
    self.shouldFitMarkers = fitMarkers;
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate updateLocation];
}
#pragma mark - handler DataModel changed
- (void)coredateChanged:(NSNotification *)info {
    // reload data source
    [self reloadDataSource];
    // update map information
    [self updateMapInfoWithFitMarkets:YES];
}
#pragma mark - event handler
- (IBAction)refreshTapped:(UIBarButtonItem *)sender {
    // get location
    [self updateMapInfoWithFitMarkets:NO];
}
- (IBAction)clearTapped:(UIBarButtonItem *)sender {
    // clear all old polylines
    for (GMSPolyline *polyline in self.mapView.polylines) {
        polyline.map = nil;
    }
}

#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
- (GMSMarker *)locationMarker {
    if (!_locationMarker) {
        _locationMarker = [self addMarketAt:CLLocationCoordinate2DMake(0.0, 0.0) snippet:@"You are here!" mapMoved:NO];
        _locationMarker.icon = [UIImage imageNamed:@"bullet_blue"];
    }
    return _locationMarker;
}
#pragma mark - Search
- (NSArray*)queryByPlace:(NSString*)placeName {
    NSArray *filteredPlaces;
    // filtering
    if (placeName.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", placeName];
        filteredPlaces = [self.places filteredArrayUsingPredicate:predicate];
    }
    else {
        filteredPlaces = self.places;
    }
    return filteredPlaces;
}
- (void)hideSearchResultWithAnimated:(BOOL)animted{
    CGRect newFrame = self.seacrhResultView.frame;
    newFrame.origin.y = -newFrame.size.height;
    if (animted) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.seacrhResultView.frame = newFrame;
                         }];
    } else {
        self.seacrhResultView.frame = newFrame;
    }
}
- (void)showSearchResult {
    CGRect newFrame = self.seacrhResultView.frame;
    newFrame.origin.y = self.searchPlaceBar.frame.origin.y + self.searchPlaceBar.frame.size.height;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.seacrhResultView.frame = newFrame;
                     }];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // ignore text edit observation in case search bar
    FEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate stopObservingFirstResponder];
    self.placeListTVC.places = [self queryByPlace:textField.text];
    [self showSearchResult];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.placeListTVC.places = [self queryByPlace:string];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    // restore text edit observation
    FEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate startObservingFirstResponder];
    [self hideSearchResultWithAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - FEPlaceListSearchMapTVCDelegate
- (void)searchMapDidSelectPlace:(Place *)place {
    [self.searchTextField resignFirstResponder];
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CLLocation* location = [delegate getCurrentLocation];
    CLLocationCoordinate2D locPlace1 = {location.coordinate.latitude, location.coordinate.longitude};
    CLLocationCoordinate2D locPlace2 = {[place.address.lattittude floatValue], [place.address.longtitude floatValue]};
    [FEMapUtility getDirectionFrom:locPlace1 to:locPlace2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSArray *locations) {
        // clear all old polylines
        for (GMSPolyline *polyline in self.mapView.polylines) {
            polyline.map = nil;
        }
        // add new polylines
        GMSMutablePath *path = [GMSMutablePath path];
        for (NSValue *value in locations) {
            CLLocationCoordinate2D location;
            [value getValue:&location];
            [path addCoordinate:location];
        }
        GMSPolyline *route = [GMSPolyline polylineWithPath:path];
        route.strokeWidth = 3;
        route.map = self.mapView;
        // fit camera
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
    }];
}
#pragma mark - Map
- (void)locationChanged:(NSNotification*)info {
    [self.indicationView stopAnimating];
    [self updateMapInfoWithFitMarkets:self.shouldFitMarkers];
}
- (void)reloadDataSource {
    // reload data source
    self.places = [Place placesFromPlaceSettingInfo:self.searchPlaceSettingInfo
                                            withMOC:self.coreData.managedObjectContext];
    // rebuild marker
    for (GMSMarker *marker in self.mapView.markers) {
        marker.map = nil;
    }
    for (Place *place in self.places) {
        CLLocationCoordinate2D location2d = {[place.address.lattittude floatValue], [place.address.longtitude floatValue]};
        [self addMarketAt:location2d snippet:place.name mapMoved:NO];
    }
}
#define MARKERS_FIT_PADDING 100.0
- (void)updateMapInfoWithFitMarkets:(BOOL)fitMarkets {
    // update myLocation
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CLLocation* myLocation = [delegate getCurrentLocation];
    if (myLocation == nil) {
        return;
    }
    CLLocationCoordinate2D myLocation2d = {myLocation.coordinate.latitude, myLocation.coordinate.longitude};
    self.locationMarker.position = myLocation2d;
    // fit Markers location
    if (fitMarkets) {
        [self fitMarkerInBound];
    }
    else {
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:myLocation2d]];
    }
    // refesh distance
    NSMutableArray *destLocations = [NSMutableArray array];
    for (Place *place in self.places) {
        CLLocationCoordinate2D to = {[place.address.lattittude floatValue], [place.address.longtitude floatValue]};
        [destLocations addObject:[NSValue valueWithBytes:&to objCType:@encode(CLLocationCoordinate2D)]];
    }
    [FEMapUtility getDistanceFrom:myLocation2d to:destLocations queue:[NSOperationQueue mainQueue] completionHandler:^(NSArray *distances) {
        for (int i = 0; i < distances.count; i++) {
            NSDictionary *distanceInfo = distances[i];
            NSString *distanceStr = distanceInfo[@"distance"];
            NSString *durationStr = distanceInfo[@"duration"];
            Place *place = self.places[i];
            place.distanceInfo = [NSString stringWithFormat:@"About %@ from here, estimate %@ driving.", distanceStr, durationStr];
        }
    }];
}
- (void)fitMarkerInBound {
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    for (GMSMarker *marker in self.mapView.markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:MARKERS_FIT_PADDING]];
}
- (GMSMarker*)addMarketAt:(CLLocationCoordinate2D)location snippet:(NSString*)snippet mapMoved:(BOOL)mapMoved{
    if (mapMoved) {
        self.mapView.camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                          longitude:location.longitude
                                                               zoom:GMAP_DEFAULT_ZOOM];
    }
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location;
    marker.snippet = snippet;
    marker.map = self.mapView;
    return marker;
}

@end
