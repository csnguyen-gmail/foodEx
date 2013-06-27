//
//  FESearchSortBaseTVC.h
//  feedEx
//
//  Created by csnguyen on 6/23/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FESearchSortBaseTVC : UITableViewController
@property (weak, nonatomic) NSNumber *tagType; // abstract
@property (weak, nonatomic) IBOutlet UITextField *tagsTF; // abstract
@property (weak, nonatomic) IBOutlet UITextField *firstSortTF; // abstract
@property (weak, nonatomic) IBOutlet UITextField *secondSortTF; // abstract
- (NSArray*)getTypeStrings; // abstract
- (IBAction)firstSortTapped:(UITextField *)sender; // abstract
- (IBAction)secondSortTapped:(UITextField *)sender; // abstract
- (IBAction)tagsTapped:(UITextField *)sender; // abstract
- (void)setFirstSortText:(NSString*)firstSort andSecondSortText:(NSString*)secondSort;
@end
