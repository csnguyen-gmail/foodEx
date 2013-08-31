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
#import "UISearchBar+Extension.h"

@interface FEMapVC()<UISearchBarDelegate, FEPlaceListSearchMapTVCDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (weak, nonatomic) FECoreDataController *coreData;
@property (strong, nonatomic) NSArray *places;
@property (nonatomic, strong) FESearchPlaceSettingInfo *searchPlaceSettingInfo;
@property (weak, nonatomic) IBOutlet UISearchBar *searchPlaceBar;
@property (weak, nonatomic) IBOutlet UIView *seacrhResultView;
@property (weak, nonatomic) FEPlaceListSearchMapTVC *placeListTVC;
@property (strong, nonatomic) NSString *searchText;
@end

@implementation FEMapVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    [self reloadDataSource];
    [self fitMarkerInBound];
    [self addLocationObervation];
    [self hideSearchResultWithAnimated:NO];
    [self.searchPlaceBar setSearchBarReturnKeyType:UIReturnKeyDone];
    self.placeListTVC.searchDelegate = self;
}
- (void)dealloc {
    [self removeLocationObservation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeList"]) {
        self.placeListTVC = [segue destinationViewController];
    }
}
#pragma mark - handler DataModel changed
- (void)handleDataModelChange:(NSNotification *)note {
    // reload data source
    [self reloadDataSource];
    // update map information
    [self updateMapInfo];
}

#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
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
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // keep text before edit for resume in case Cancel
    self.searchText = searchBar.text;
    // ignore text edit observation in case search bar
    FEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate stopObservingFirstResponder];
    self.placeListTVC.places = [self queryByPlace:searchBar.text];
    [self showSearchResult];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.placeListTVC.places = [self queryByPlace:searchText];
    self.searchText = searchBar.text;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // restore text edit observation
    FEAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate startObservingFirstResponder];
    [self hideSearchResultWithAnimated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = self.searchText;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
#pragma mark - FEPlaceListSearchMapTVCDelegate
- (void)searchMapDidSelectPlace:(Place *)place {
    [self.searchPlaceBar resignFirstResponder];
    CLLocation* location = self.mapView.myLocation;
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
- (void)addLocationObervation {
    [self.indicationView startAnimating];
    if (!self.mapView.myLocationEnabled) {
        self.mapView.myLocationEnabled = YES;
        [self.mapView addObserver:self forKeyPath:GMAP_LOCATION_OBSERVE_KEY options:NSKeyValueObservingOptionNew context: nil];
    }
}
- (void)removeLocationObservation {
    [self.indicationView stopAnimating];
    if (self.mapView.myLocationEnabled) {
        self.mapView.myLocationEnabled = NO;
        [self.mapView removeObserver:self forKeyPath:GMAP_LOCATION_OBSERVE_KEY];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self removeLocationObservation];
    if ([keyPath isEqualToString:GMAP_LOCATION_OBSERVE_KEY] && [object isKindOfClass:[GMSMapView class]]) {
        [self updateMapInfo];
    }
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
- (void)updateMapInfo {
    // fit Markers location
    CLLocation* myLocation = self.mapView.myLocation;
    CLLocationCoordinate2D myLocation2d = {myLocation.coordinate.latitude, myLocation.coordinate.longitude};
    GMSMarker *marker = [self addMarketAt:myLocation2d snippet:@"You are here!" mapMoved:NO];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:myLocation2d coordinate:myLocation2d];
    for (GMSMarker *marker in self.mapView.markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
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
    return marker;
}

@end
