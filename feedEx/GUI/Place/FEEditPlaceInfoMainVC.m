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
    float _originUpperHeight;
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
    [self setScrollView:nil];
    [self setVerticalResizeView:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    _originUpperHeight = self.scrollView.frame.size.height;
}

#pragma mark - Additional functions
- (void)setupGUI {
    // map view
    self.mapView.layer.cornerRadius = 10;
    
    // edit place info view
    self.editPlaceInfoTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPlaceInfoTVC"];
    self.editPlaceInfoTVC.tableView.layer.cornerRadius = 10;
    self.editPlaceInfoTVC.tableView.frame = CGRectMake(0, 0,
                                                       self.scrollView.bounds.size.width,
                                                       [self.editPlaceInfoTVC getHeightOfTable]);
    [self addChildViewController:self.editPlaceInfoTVC];
    self.scrollView.layer.cornerRadius = 10;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, [self.editPlaceInfoTVC getHeightOfTable] - 0);
    [self.scrollView addSubview:self.editPlaceInfoTVC.tableView];
    self.scrollView.autoresizesSubviews = NO;
    // vertical resize controller view
    self.verticalResizeView.delegate = self;
    _limitUpperHeight = [self.editPlaceInfoTVC.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].size.height - 0;
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
    UIView *upperView = self.scrollView;
    UIView *verticalControllerView = self.verticalResizeView;
    if (delta == .0f) {
        return;
    }
    if ((lowerView.frame.size.height - delta) < _limitLowerHeight) {
        if (lowerView.frame.size.height == _limitLowerHeight) {
            return;
        }
        delta = lowerView.frame.size.height - _limitLowerHeight;
    }
    if ((upperView.frame.size.height + delta) < _limitUpperHeight) {
        if (upperView.frame.size.height == _limitUpperHeight) {
            return;
        }
        delta = _limitUpperHeight - upperView.frame.size.height;
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
        delta = self.scrollView.frame.size.height - _originUpperHeight;
    }
    else {
        delta = self.scrollView.frame.size.height - _limitUpperHeight;
    }
    
    [UIView animateWithDuration:.3f animations:^{
        [self verticalResizeControllerDidChanged:-delta];
    }];
    

}

@end
