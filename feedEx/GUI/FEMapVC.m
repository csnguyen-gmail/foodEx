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

@interface FEMapVC()
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (weak, nonatomic) FECoreDataController *coreData;
@property (strong, nonatomic) NSArray *places;
@end

@implementation FEMapVC
// TODO: when to update database
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLocationObervation];
}
- (void)dealloc {
    [self removeLocationObservation];
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
        CLLocationCoordinate2D location2d = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        GMSMarker *marker = [self addMarketAt:location2d snippet:@"" mapMoved:YES];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
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
    marker.map = self.mapView;
    return marker;
}

@end
