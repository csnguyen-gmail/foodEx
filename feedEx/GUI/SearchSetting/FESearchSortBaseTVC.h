//
//  FESearchSortBaseTVC.h
//  feedEx
//
//  Created by csnguyen on 6/23/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FESearchSortBaseTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *firstSortTF; // abstract
@property (weak, nonatomic) IBOutlet UITextField *secondSortTF; // abstract
- (void)setFirstSortText:(NSString*)firstSort andSecondSortText:(NSString*)secondSort;
- (NSArray*)getTypeStrings; // abstract
@end
