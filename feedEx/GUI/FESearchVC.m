//
//  FESearchVC.m
//  feedEx
//
//  Created by csnguyen on 6/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchVC.h"
#import "FEPlaceListTVC.h"

@interface FESearchVC ()
@property (weak, nonatomic) IBOutlet UIView *placeHolderView;
@property (weak, nonatomic) FEPlaceListTVC *placeListView;
@end

@implementation FESearchVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    [self addChildViewController:self.placeListView];
    [self.placeHolderView addSubview:self.placeListView.view];
    [self showViewByType:0]; // TODO
}
- (IBAction)showTypeChange:(UISegmentedControl *)sender {
    [self showViewByType:sender.selectedSegmentIndex];
}
- (void)showViewByType:(NSInteger)type {
    // TODO
}

#pragma mark - getter setter
- (FEPlaceListTVC *)placeListView {
    if (!_placeListView) {
        _placeListView = [self.storyboard instantiateViewControllerWithIdentifier:[[FEPlaceListTVC class] description]];
    }
    return _placeListView;
}
@end
