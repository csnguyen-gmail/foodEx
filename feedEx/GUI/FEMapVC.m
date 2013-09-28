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
#import "Place+Extension.h"
#import "Address.h"
#import "FEMapUtility.h"
#import "FEPlaceListSearchMapTVC.h"
#import "FEAppDelegate.h"
#import "FEMapSearchSettingVC.h"

@interface FEMapVC()<FEPlaceListSearchMapTVCDelegate, UITextFieldDelegate, FEMapSearchSettingVCDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (strong, nonatomic) NSArray *places;
@property (weak, nonatomic) IBOutlet UIToolbar *searchPlaceBar;
@property (weak, nonatomic) IBOutlet UIView *seacrhResultView;
@property (weak, nonatomic) FEPlaceListSearchMapTVC *placeListTVC;
@property (weak, nonatomic) GMSMarker *locationMarker;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) BOOL shouldFitMarkers;
@property (nonatomic, strong) FEMapSearchPlaceSettingInfo *searchSettingInfo;
@end

@implementation FEMapVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.settings.compassButton = YES;
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

    [self refetchData];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_UPDATED object:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeList"]) {
        self.placeListTVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"mapSetting"]) {
        FEMapSearchSettingVC *settingVC = [segue destinationViewController];
        settingVC.delegate = self;
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
    [self refetchData];
    // update map information
    [self updateMapInfoWithFitMarkets:YES];
}
- (void)refetchData {
    // reload data source
    self.places = [Place placesFromMapPlaceSettingInfo:self.searchSettingInfo];
    // rebuild marker
    for (GMSMarker *marker in self.mapView.markers) {
        marker.map = nil;
    }
    for (Place *place in self.places) {
        CLLocationCoordinate2D location2d = {[place.address.lattittude floatValue], [place.address.longtitude floatValue]};
        [self addMarketAt:location2d snippet:place.name mapMoved:NO];
    }
}

#pragma mark - event handler
- (IBAction)refreshTapped:(UIBarButtonItem *)sender {
    // get location
    [self updateLocationWithFitMarker:NO];
}
- (IBAction)clearTapped:(UIBarButtonItem *)sender {
    // clear all old polylines
    for (GMSPolyline *polyline in self.mapView.polylines) {
        polyline.map = nil;
    }
}

#pragma mark - getter setter
- (GMSMarker *)locationMarker {
    if (!_locationMarker) {
        _locationMarker = [self addMarketAt:CLLocationCoordinate2DMake(0.0, 0.0) snippet:@"You are here!" mapMoved:NO];
        _locationMarker.icon = [UIImage imageNamed:@"bullet_blue"];
    }
    return _locationMarker;
}
- (FEMapSearchPlaceSettingInfo *)searchSettingInfo {
    if (!_searchSettingInfo) {
        NSData *archivedObject = [[NSUserDefaults standardUserDefaults] objectForKey:MAP_SEARCH_SETTING_KEY];
        if (archivedObject) {
            _searchSettingInfo = (FEMapSearchPlaceSettingInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
        }
        else {
            _searchSettingInfo = [[FEMapSearchPlaceSettingInfo alloc] init];
        }
    }
    return _searchSettingInfo;
}

#pragma mark - Search
- (NSArray*)queryByKeyword:(NSString*)searchKeyword {
    NSArray *filteredPlaces;
    // filtering
    if (searchKeyword.length > 0) {
        NSPredicate *predicate;
        if (self.searchSettingInfo.searchBy == SEARCH_BY_NAME) {
            predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchKeyword];
        }
        else if (self.searchSettingInfo.searchBy == SEARCH_BY_ADDRESS) {
            predicate = [NSPredicate predicateWithFormat:@"address.address CONTAINS[cd] %@", searchKeyword];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR address.address CONTAINS[cd] %@", searchKeyword, searchKeyword];
        }
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
    self.placeListTVC.places = [self queryByKeyword:textField.text];
    [self showSearchResult];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.placeListTVC.places = [self queryByKeyword:[textField.text stringByReplacingCharactersInRange:range withString:string]];
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
#pragma mark - FESearchSettingVCDelegate
- (void)didFinishSetting:(FEMapSearchPlaceSettingInfo *)searchSetting hasModification:(BOOL)hasModification {
    if (hasModification) {
        self.searchSettingInfo = searchSetting;
        [self refetchData];
    }
}

@end
