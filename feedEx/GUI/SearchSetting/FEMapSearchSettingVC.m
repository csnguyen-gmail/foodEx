//
//  FEMapSearchSettingVC.m
//  feedEx
//
//  Created by csnguyen on 9/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEMapSearchSettingVC.h"
#import "DYRateView.h"
#import "FESearchTagVC.h"
#import "CoredataCommon.h"
#import <QuartzCore/QuartzCore.h>

@interface FEMapSearchSettingVC ()
@property (weak, nonatomic) IBOutlet DYRateView *ratingView;
@property (weak, nonatomic) FESearchTagVC *searchTagVC;
@end

@implementation FEMapSearchSettingVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ratingView setupBigStarEditable:YES];
    self.searchTagVC.view.backgroundColor = [UIColor clearColor];
    self.searchTagVC.view.layer.cornerRadius = 10.0;
    self.searchTagVC.view.layer.masksToBounds = YES;
    self.searchTagVC.view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.searchTagVC.view.layer.borderWidth = 1.0;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"tagSelection"]) {
        self.searchTagVC = [segue destinationViewController];
        [self.searchTagVC loadTagWithTagType:CD_TAG_PLACE andSelectedTags:nil];
    }
}

@end
