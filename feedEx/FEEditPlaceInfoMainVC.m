//
//  FEEditPlaceInfoMainVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoMainVC.h"

@interface FEEditPlaceInfoMainVC ()

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
    [super viewDidUnload];
}

#pragma mark - Additional functions
- (void)setupGUI {
    // make rounded rectangle table
    self.mapView.layer.cornerRadius = 10;
    self.placeInfoView.layer.cornerRadius = 10;
    self.editPlaceInfoTVC.tableView.layer.cornerRadius = 10;
    self.placeInfoView.contentSize = CGSizeMake(self.placeInfoView.bounds.size.width, 300);
    self.editPlaceInfoTVC.tableView.frame = CGRectMake(0, 0, self.placeInfoView.bounds.size.width, 300);
    [self addChildViewController:self.editPlaceInfoTVC];
    [self.placeInfoView addSubview:self.editPlaceInfoTVC.tableView];
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
    // load EditPlaceInfoTVC
    self.editPlaceInfoTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPlaceInfoTVC"];
}

@end
