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
#import "FEDirection.h"

@interface FEMapVC()
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (weak, nonatomic) FECoreDataController *coreData;
@property (strong, nonatomic) NSArray *places;
@property (nonatomic, strong) FESearchPlaceSettingInfo *searchPlaceSettingInfo;
@end

@implementation FEMapVC
// TODO: when to update database
- (void)viewDidLoad {
    [super viewDidLoad];
    self.needUpdateDatabase = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    [self addLocationObervation];
}
- (void)dealloc {
    [self removeLocationObservation];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.needUpdateDatabase) {
        self.places = [Place placesFromPlaceSettingInfo:self.searchPlaceSettingInfo
                                                withMOC:self.coreData.managedObjectContext];
        for (GMSMarker *marker in self.mapView.markers) {
            marker.map = nil;
        }
        for (Place *place in self.places) {
            CLLocationCoordinate2D location2d = {[place.address.lattittude floatValue], [place.address.longtitude floatValue]};
            [self addMarketAt:location2d snippet:place.name mapMoved:NO];
        }
        self.needUpdateDatabase = NO;
    }
}

#pragma mark - getter setter
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
#pragma mark - Map
- (void)addLocationObervation {
    self.indicationView.hidden = NO;
    [self.indicationView startAnimating];
    if (!self.mapView.myLocationEnabled) {
        self.mapView.myLocationEnabled = YES;
        [self.mapView addObserver:self forKeyPath:GMAP_LOCATION_OBSERVE_KEY options:NSKeyValueObservingOptionNew context: nil];
    }
}
- (void)removeLocationObservation {
    [self.indicationView stopAnimating];
    self.indicationView.hidden = YES;
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
        CLLocationCoordinate2D location2d = {location.coordinate.latitude, location.coordinate.longitude};
        GMSMarker *marker = [self addMarketAt:location2d snippet:@"" mapMoved:NO];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:location2d coordinate:location2d];
        for (GMSMarker *marker in self.mapView.markers) {
            bounds = [bounds includingCoordinate:marker.position];
        }
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        
        // TODO:test only
        Place *place1 = self.places[0];
        Place *place2 = self.places[1];
        CLLocationCoordinate2D locPlace1 = {[place1.address.lattittude floatValue], [place1.address.longtitude floatValue]};
        CLLocationCoordinate2D locPlace2 = {[place2.address.lattittude floatValue], [place2.address.longtitude floatValue]};
        [FEDirection getDirectionFrom:locPlace1 to:locPlace2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSArray *locations) {
            GMSMutablePath *path = [GMSMutablePath path];
            for (NSValue *value in locations) {
                CLLocationCoordinate2D location;
                [value getValue:&location];
                [path addCoordinate:location];
            }
            GMSPolyline *route = [GMSPolyline polylineWithPath:path];
            route.strokeWidth = 3;
            route.map = self.mapView;
        }];
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
