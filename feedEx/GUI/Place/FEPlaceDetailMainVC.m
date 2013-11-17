//
//  FEPlaceDetailVC.m
//  feedEx
//
//  Created by csnguyen on 7/8/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceDetailMainVC.h"
#import "Photo.h"
#import "FEPlaceEditMainVC.h"
#import "FEPlaceDetailFoodCell.h"
#import "FEPlaceDetailTVC.h"
#import "Address.h"
#import "Common.h"
#import "User+Extension.h"
#import "FEVerticalResizeControllView.h"
#import "FEFoodDetailVC.h"
#import "FEDataSerialize.h"
#import "FEAppDelegate.h"
#import "FEMapUtility.h"
#import <MessageUI/MessageUI.h>

@interface FEPlaceDetailMainVC ()<FEVerticalResizeControlDelegate, FEPlaceDetailTVCDelegate,MFMailComposeViewControllerDelegate, UIActionSheetDelegate>{
    float _minResizableHeight;
    float _maxResizableHeight;
}
@property (weak, nonatomic) IBOutlet UILabel *addressLbl;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapBgView;
@property (weak, nonatomic) FEPlaceDetailTVC *placeDetailTVC;
@property (weak, nonatomic) IBOutlet UIView *placeDetailView;
@property (weak, nonatomic) IBOutlet FEVerticalResizeControllView *verticalResizeView;
@property (nonatomic) NSUInteger selectedIndex;
@property (weak, nonatomic) GMSMarker *placeMarker;
@property (weak, nonatomic) IBOutlet UILabel *distanceInfo;
@property (weak, nonatomic) IBOutlet UIView *distanceInfoBgView;
@end

@implementation FEPlaceDetailMainVC
#define TAG_PADDING 5.0
#define TAG_HORIZON_MARGIN 10.0
#define TAG_VERTICAL_MARGIN 5.0
- (void)viewDidLoad {
    [super viewDidLoad];
    self.verticalResizeView.delegate = self;
    self.placeDetailTVC.place = self.place;
    self.addressLbl.text = self.place.address.address;
    _minResizableHeight = 34;
    _maxResizableHeight = self.placeDetailView.frame.size.height;
    // map
    self.mapBgView.layer.cornerRadius = 10.0;
    self.mapBgView.layer.masksToBounds = YES;
    float lattittude = [self.place.address.lattittude floatValue];
    float longtitude = [self.place.address.longtitude floatValue];
    if (longtitude != 0 && lattittude != 0) {
        self.mapView.camera = [GMSCameraPosition cameraWithLatitude:lattittude
                                                          longitude:longtitude
                                                               zoom:GMAP_DEFAULT_ZOOM];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lattittude, longtitude);
        marker.map = self.mapView;
        self.placeMarker = marker;
    }
    else {
        self.mapView.camera = [GMSCameraPosition cameraWithLatitude:HCM_LATITUDE
                                                          longitude:HCM_LONGTITUDE
                                                               zoom:GMAP_DEFAULT_ZOOM];
    }
    self.placeDetailTVC.placeDetailTVCDelegate = self;
    // core data changed tracking register
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coredateChanged:)
                                                 name:CORE_DATA_UPDATED object:nil];
    // location change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:)
                                                 name:LOCATION_UPDATED object:nil];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CORE_DATA_UPDATED object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"editPlace"]) {
        UINavigationController *navigation = [segue destinationViewController];
        FEPlaceEditMainVC *editPlaceInfoMainVC = navigation.viewControllers[0];
        editPlaceInfoMainVC.placeInfo = self.place;
    }
    else if ([[segue identifier] isEqualToString:@"placeDetailTVC"]) {
        self.placeDetailTVC = [segue destinationViewController];
    }
    else if ([[segue identifier] isEqualToString:@"foodDetailVC"]) {
        FEFoodDetailVC *foodDetailVC = [segue destinationViewController];
        foodDetailVC.food = self.place.foods[self.selectedIndex];
    }
}
- (void)sharePlace {
    User *user = [User getUser];
    NSDictionary *placeInfo = @{USER_KEY:user, PLACES_KEY:@[self.place]};
    NSData *sendingData = [FEDataSerialize serializeMailData:placeInfo];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ATTACHED_FILENAME_DATE_FORMAT;
    NSDate *now = [[NSDate alloc] init];
    NSString *filename = [NSString stringWithFormat:ATTACHED_FILENAME_FORMAT, [dateFormatter stringFromDate:now]];
    NSMutableString *body = [[NSMutableString alloc] initWithString:MAIL_BODY];
    [body appendString:[NSString stringWithFormat:@"+%@\n", self.place.name]];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker setSubject:MAIL_SUBJECT];
    [picker addAttachmentData:sendingData mimeType:ATTACHED_FILETYPE fileName:filename];
    [picker setToRecipients:[NSArray array]];
    [picker setMessageBody:body isHTML:NO];
    [picker setMailComposeDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)gotoPlace {
    // update location
    FEAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate updateLocation];
}
#pragma mark - Map
#define MARKERS_FIT_PADDING 70.0
- (void)locationChanged:(NSNotification *)info {
    // create current location marker
    CLLocation* location = [info userInfo][@"location"];
    CLLocationCoordinate2D location2d = {location.coordinate.latitude, location.coordinate.longitude};
    
    // create current location
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location2d;
    marker.map = self.mapView;
    marker.icon = [UIImage imageNamed:@"bullet_blue"];
    // find route
    CLLocationCoordinate2D locPlace1 = location2d;
    CLLocationCoordinate2D locPlace2 = self.placeMarker.position;
    [FEMapUtility getDirectionFrom:locPlace1 to:locPlace2 queue:[NSOperationQueue mainQueue] completionHandler:^(NSArray *locations) {
        // expand map view
        CGFloat delta = self.placeDetailView.frame.size.height - _minResizableHeight;
        [UIView animateWithDuration:.3f animations:^{
            [self verticalResizeControllerDidChanged:-delta];
        }];
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
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:MARKERS_FIT_PADDING]];
    }];
    // find distance
    NSValue *locPlace2Value = [NSValue valueWithBytes:&locPlace2 objCType:@encode(CLLocationCoordinate2D)];
    [FEMapUtility getDistanceFrom:locPlace1 to:@[locPlace2Value]
                            queue:[NSOperationQueue mainQueue]
                completionHandler:^(NSArray *distances) {
                    if (distances.count > 0) {
                        NSDictionary *distanceInfo = distances[0];
                        NSString *distanceStr = distanceInfo[@"distance"];
                        NSString *durationStr = distanceInfo[@"duration"];
                        NSString *infoStr = [NSString stringWithFormat:@"(about %@ from here, estimate %@ driving)", distanceStr, durationStr];
                        [UIView animateWithDuration:0.3 animations:^{
                            self.distanceInfo.text = infoStr;
                            self.distanceInfo.hidden = NO;
                            self.distanceInfoBgView.hidden = NO;
                        }];
                    }
    }];
}
#pragma mark - handler DataModel changed
- (void)coredateChanged:(NSNotification *)info {
    self.placeDetailTVC.place = self.place;
}
#pragma mar - handler action
- (IBAction)actionTapped:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit", @"Share", @"Go to", nil];
//    [actionSheet showInView:self.view];
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - FEVerticalResizeControlDelegate
- (void)verticalResizeControllerDidChanged:(float)delta {
    UIView *lowerView = self.mapBgView;
    UIView *upperView = self.placeDetailView;
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
    CGFloat delta;
    if (self.verticalResizeView.frame.origin.y < self.view.frame.size.height / 2) {
        delta = self.placeDetailView.frame.size.height - _maxResizableHeight;
    }
    else {
        delta = self.placeDetailView.frame.size.height - _minResizableHeight;
    }
    
    [UIView animateWithDuration:.3f animations:^{
        [self verticalResizeControllerDidChanged:-delta];
    }];
}
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - FEPlaceDetailTVCDelegate
- (void)didSelectItemAtIndexPath:(NSUInteger)index {
    self.selectedIndex = index;
    [self performSegueWithIdentifier:@"foodDetailVC" sender:self];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: // Edit
            [self performSegueWithIdentifier:@"editPlace" sender:self];
            break;
        case 1: // Share
            [self sharePlace];
            break;
        case 2: // Goto
            [self gotoPlace];
            break;
        default:
            break;
    }
}
@end
