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
#import "Photo.h"
#import "ThumbnailPhoto.h"
#import "FEMapUtility.h"
#import "FEPlaceListSearchMapTVC.h"
#import "FEAppDelegate.h"
#import "FEMapSearchSettingVC.h"
#import "FEMapMarkerView.h"
#import "Tag.h"
#import "FEPlaceDetailMainVC.h"

@interface FEArrowView : UIView
@end
@implementation FEArrowView
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, 0.0, 0.0);
    CGContextAddLineToPoint(ctx, rect.size.width, 0.0);
    CGContextAddLineToPoint(ctx, rect.size.width / 2, rect.size.height);
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.8);
    CGContextFillPath(ctx);
}
@end

@interface FEMapVC()<FEPlaceListSearchMapTVCDelegate, UITextFieldDelegate, FEMapSearchSettingVCDelegate, GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
@property (strong, nonatomic) NSArray *places;
@property (weak, nonatomic) IBOutlet UIToolbar *searchPlaceBar;
@property (weak, nonatomic) IBOutlet UIView *seacrhResultView;
@property (weak, nonatomic) FEPlaceListSearchMapTVC *placeListTVC;
@property (weak, nonatomic) GMSMarker *locationMarker;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) BOOL shouldFitMarkers;
@property (nonatomic) BOOL shouldUpdateCamera;
@property (nonatomic, strong) FEMapSearchPlaceSettingInfo *searchSettingInfo;
@property (nonatomic, strong) Place *selectedPlace;
@end

@implementation FEMapVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.settings.compassButton = YES;
    [self fitMarkerInBound];
    [self hideSearchResultWithAnimated:NO];
    self.placeListTVC.searchDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coredateChanged:)
                                                 name:CORE_DATA_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:)
                                                 name:LOCATION_UPDATED object:nil];
    // update marker
    [self refetchData];
    self.shouldFitMarkers = YES;
    [self updateMapInfo];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"placeList"]) {
        self.placeListTVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"mapSetting"]) {
        FEMapSearchSettingVC *settingVC = [segue destinationViewController];
        settingVC.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"detailPlace"]) {
        UINavigationController *nav = [segue destinationViewController];
        FEPlaceDetailMainVC *placeDetailVC = nav.viewControllers[0];
        placeDetailVC.place = self.selectedPlace;
    }
}

#pragma mark - handler DataModel changed
- (void)coredateChanged:(NSNotification *)info {
    // reload data source
    [self refetchData];
    // update map information
    self.shouldFitMarkers = YES;
    [self updateMapInfo];
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
        [self addMarketAt:location2d withPlace:place mapMoved:NO];
    }
}

#pragma mark - event handler
- (IBAction)refreshTapped:(UIBarButtonItem *)sender {
    // get location
    self.shouldFitMarkers = NO;
    self.shouldUpdateCamera = YES;
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate updateLocation];
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
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.placeListTVC.places = [self queryByKeyword:nil];
    return YES;
}
#pragma mark - FEPlaceListSearchMapTVCDelegate
- (void)searchMapDidSelectPlace:(Place *)place {
    [self.searchTextField resignFirstResponder];
    for (GMSMarker *marker in self.mapView.markers) {
        if ((marker.position.longitude == [place.address.longtitude doubleValue]) &&
            (marker.position.latitude == [place.address.lattittude doubleValue])) {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        }
        else {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        }
    }
    
    
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CLLocation* location = [delegate getCurrentLocation];
    CLLocationCoordinate2D locPlace1 = {location.coordinate.latitude, location.coordinate.longitude};
    CLLocationCoordinate2D locPlace2 = {[place.address.lattittude floatValue], [place.address.longtitude floatValue]};
    [[FEMapUtility sharedInstance] getDirectionFrom:locPlace1 to:locPlace2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSArray *locations) {
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
    [self updateMapInfo];
}
#define MARKERS_FIT_PADDING 40.0
- (void)updateMapInfo {
    // update myLocation
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CLLocation* myLocation = [delegate getCurrentLocation];
    if (myLocation == nil) {
        return;
    }
    CLLocationCoordinate2D myLocation2d = {myLocation.coordinate.latitude, myLocation.coordinate.longitude};
    self.locationMarker.position = myLocation2d;
    // fit Markers location
    if (self.shouldFitMarkers) {
        [self fitMarkerInBound];
        self.shouldFitMarkers = NO;
    }
    else {
        if (self.shouldUpdateCamera) {
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:myLocation2d]];
            self.shouldUpdateCamera = NO;
        }
    }
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
- (GMSMarker*)addMarketAt:(CLLocationCoordinate2D)location withPlace:(Place*)place mapMoved:(BOOL)mapMoved{
    if (mapMoved) {
        self.mapView.camera = [GMSCameraPosition cameraWithLatitude:location.latitude
                                                          longitude:location.longitude
                                                               zoom:GMAP_DEFAULT_ZOOM];
    }
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location;
    marker.userData = place;
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
#pragma mark - GMSMapViewDelegate
#define TAG_PADDING 5.0
#define TAG_HORIZON_MARGIN 10.0
#define TAG_VERTICAL_MARGIN 5.0
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    if (marker.userData == nil) {
        return nil;
    }
    // content view
    Place *place = marker.userData;
    FEMapMarkerView *mapMarkerView = [[[NSBundle mainBundle] loadNibNamed:@"FEMapMarkerCallout" owner:self options:nil] objectAtIndex:0];
    mapMarkerView.layer.cornerRadius = 5;
    mapMarkerView.layer.masksToBounds = YES;
    
    if (place.photos.count != 0) {
        Photo *photo = place.photos[0];
        mapMarkerView.imageView.image = photo.thumbnailPhoto.image;
    }
    mapMarkerView.nameLbl.text = place.name;
    mapMarkerView.rateView.rate = [place.rating floatValue];
    mapMarkerView.addressLbl.text = place.address.address;
    mapMarkerView.checkinLbl.text = [place.timesCheckin description];
    // flag to prevent looping in getting distance info
    if (place.distanceInfo) {
        mapMarkerView.distanceLbl.text = place.distanceInfo;
    }
    else {
        mapMarkerView.distanceLbl.text = @"";
        CLLocationCoordinate2D placeLoc = CLLocationCoordinate2DMake([place.address.lattittude doubleValue], [place.address.longtitude doubleValue]);
        [[FEMapUtility sharedInstance] getDistanceToDestination:placeLoc queue:[NSOperationQueue mainQueue] completionHandler:^(FEDistanseInfo *info) {
            place.distanceInfo = [NSString stringWithFormat:@"About %@ from here, estimate %@ driving.", info.distance, info.duration];
            // trick to refresh marker info
            if (mapView.selectedMarker == marker) {
                mapView.selectedMarker = marker;
            }
        }];
    }
    if (place.tags.count > 0) {
        CGFloat contentWidth = 0.0;
        for (Tag *tag in place.tags) {
            UIFont *font = [UIFont systemFontOfSize:10];
            CGSize tagSize = [tag.label sizeWithFont:font];
            tagSize.width += TAG_HORIZON_MARGIN;
            tagSize.height += TAG_VERTICAL_MARGIN;
            UILabel *tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth, 0, tagSize.width, tagSize.height)];
            tagLbl.adjustsFontSizeToFitWidth = YES;
            tagLbl.minimumScaleFactor = 0.1;
            tagLbl.textAlignment = NSTextAlignmentCenter;
            tagLbl.text = tag.label;
            tagLbl.font = font;
            tagLbl.textColor = [UIColor whiteColor];
            tagLbl.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1];
            tagLbl.layer.cornerRadius = 5;
            tagLbl.layer.borderColor = [[UIColor whiteColor] CGColor];
            tagLbl.layer.borderWidth = 0.8;
            [mapMarkerView.tagsScrollView addSubview:tagLbl];
            contentWidth += tagSize.width + TAG_PADDING;
        }
        CGSize size = mapMarkerView.tagsScrollView.contentSize;
        size.width = contentWidth;
        mapMarkerView.tagsScrollView.contentSize = size;
    }

    // anchor
    CGFloat anchorHeight = 10.0;
    CGFloat popupWidth = mapMarkerView.frame.size.width;
    CGFloat popupHeight = mapMarkerView.frame.size.height + anchorHeight;
    UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popupWidth, popupHeight)];
    CGRect arrowRect = CGRectMake(popupWidth / 2 - anchorHeight, popupHeight- anchorHeight, anchorHeight *2, anchorHeight);
    FEArrowView *arrowView = [[FEArrowView alloc] initWithFrame:arrowRect];
    arrowView.backgroundColor = [UIColor clearColor];
    
    [outerView addSubview:arrowView];
    [outerView addSubview:mapMarkerView];
    
    return outerView;
}
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if (marker.userData == nil) {
        return;
    }
    self.selectedPlace = marker.userData;
    [self performSegueWithIdentifier:@"detailPlace" sender:self];
}
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    Place *place = marker.userData;
    place.distanceInfo = nil;
    // let map do thier job
    return NO;
}
@end
