//
//  FEEditPlaceInfoMainVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoMainVC.h"

@interface FEEditPlaceInfoMainVC (){
    NSUInteger _limitLowerHeight;
    NSUInteger _limitUpperHeight;
}

@end

@implementation FEEditPlaceInfoMainVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self setupGUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [self setPlaceInfoView:nil];
    [self setVerticalResizeController:nil];
    [super viewDidUnload];
}


#pragma mark - Additional functions
- (void)setupGUI {
    // map view
    self.mapView.layer.cornerRadius = 10;
    // edit place info view
    self.editPlaceInfoTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPlaceInfoTVC"];
    self.editPlaceInfoTVC.tableView.layer.cornerRadius = 10;
    self.editPlaceInfoTVC.tableView.frame = CGRectMake(0, 0, self.placeInfoView.bounds.size.width, [self.editPlaceInfoTVC getHeightOfTable]);
    [self addChildViewController:self.editPlaceInfoTVC];
    self.placeInfoView.layer.cornerRadius = 10;
    self.placeInfoView.contentSize = CGSizeMake(self.placeInfoView.bounds.size.width, [self.editPlaceInfoTVC getHeightOfTable] + 4);
    [self.placeInfoView addSubview:self.editPlaceInfoTVC.tableView];
    self.placeInfoView.autoresizesSubviews = NO;
    // vertical resize controller view
    self.verticalResizeController.delegate = self;
    _limitUpperHeight = [self.editPlaceInfoTVC.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].size.height;
    _limitLowerHeight = self.mapView.frame.size.height;
    
}

- (void)loadData {
    // load map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;
    
}
#pragma mark - FEVerticalResizeControllProtocol
- (void)verticalResizeControllerDidChanged:(float)delta {
    UIView *lowerView = self.mapView;
    UIView *upperView = self.placeInfoView;
    UIView *verticalControllerView = self.verticalResizeController;
    if ((lowerView.frame.size.height - delta) < _limitLowerHeight) {
        return;
    }
    else if ((upperView.frame.size.height + delta) < _limitUpperHeight) {
        return;
    }
    verticalControllerView.frame = CGRectMake(verticalControllerView.frame.origin.x,
                                              verticalControllerView.frame.origin.y + delta,
                                              verticalControllerView.frame.size.width,
                                              verticalControllerView.frame.size.height);
    [verticalControllerView setNeedsDisplay];
    NSLog(@"scrollView: %@", NSStringFromCGRect(self.placeInfoView.frame));
    NSLog(@"contentSize: %@", NSStringFromCGSize(self.placeInfoView.contentSize));
    NSLog(@"View: %@", NSStringFromCGRect(self.editPlaceInfoTVC.view.frame));
    NSLog(@"tableView: %@", NSStringFromCGRect(self.editPlaceInfoTVC.tableView.frame));
    
    lowerView.frame = CGRectMake(lowerView.frame.origin.x,
                                 lowerView.frame.origin.y + delta,
                                 lowerView.frame.size.width,
                                 lowerView.frame.size.height - delta);
    [lowerView setNeedsDisplay];
    upperView.frame = CGRectMake(upperView.frame.origin.x,
                                 upperView.frame.origin.y,
                                 upperView.frame.size.width,
                                 upperView.frame.size.height + delta);
    [upperView setNeedsDisplay];
    self.placeInfoView.contentSize = CGSizeMake(self.placeInfoView.bounds.size.width, [self.editPlaceInfoTVC getHeightOfTable] + 4);
}

@end
