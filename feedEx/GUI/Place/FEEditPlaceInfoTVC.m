//
//  FEEditPlaceInfoTVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoTVC.h"
#import <QuartzCore/QuartzCore.h>

@interface FEEditPlaceInfoTVC ()
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (strong, nonatomic) NSMutableArray *imagesArray;
@end

@implementation FEEditPlaceInfoTVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self setupGUI];
}

- (void)viewDidUnload {
    [self setNoteTextView:nil];
    [self setPhotoScrollView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Additional functions
- (void)setupGUI {
    // make rounded rectangle table
    self.tableView.layer.cornerRadius = 10;
    self.tableView.bounces = NO;
    self.noteTextView.layer.cornerRadius = 10;
    self.noteTextView.layer.borderWidth = 1;
    self.noteTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    // images
    int x = 0;
    for (int i = 0; i < self.imagesArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.imagesArray[i]];
        imageView.frame = CGRectMake(x, 0, 64, 64);
        [self.photoScrollView addSubview:imageView];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 10;
        imageView.layer.borderColor = [[UIColor yellowColor] CGColor];
        imageView.layer.borderWidth = i == 0 ? 2: 0;
        x += 64 + 2;
    }
    self.photoScrollView.contentSize = CGSizeMake((64 + 2) * self.imagesArray.count, 64);
}

- (void)loadData {
    self.imagesArray = [[NSMutableArray alloc] initWithArray:
                        @[[UIImage imageNamed:@"a.jpg"],
                          [UIImage imageNamed:@"b.jpg"],
                          [UIImage imageNamed:@"c.jpg"],
                          [UIImage imageNamed:@"d.jpg"],
                          [UIImage imageNamed:@"e.jpg"]]];
    
}

- (NSUInteger)getHeightOfTable {
    CGRect rect = [self.tableView rectForSection:0];
    return rect.size.height;
}

@end
