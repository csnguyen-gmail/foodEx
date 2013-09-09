//
//  FECheckinVC.m
//  feedEx
//
//  Created by csnguyen on 9/9/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "Place+Extension.h"
#import "FECheckinVC.h"
#import "FEPlaceListCheckinCell.h"
#import <QuartzCore/QuartzCore.h>
@interface FECheckinVC()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *placesTV;
@property (nonatomic, strong) NSArray *places; // array of Place
@end

@implementation FECheckinVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.placesTV.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.placesTV.layer.cornerRadius = 10;
}

#pragma mark - common
- (void)updateCell:(FEPlaceListCheckinCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    // TODO
}

#pragma mark - Table data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.places.count;
    return 10;// TODO
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PlaceListCheckinCell";
    FEPlaceListCheckinCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath];
    return cell;
}

@end
