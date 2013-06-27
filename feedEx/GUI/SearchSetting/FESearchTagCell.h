//
//  FESearchTagCell.h
//  feedEx
//
//  Created by csnguyen on 6/27/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FESearchTagCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkView;
@property (weak, nonatomic) IBOutlet UILabel *tagName;
@property (weak, nonatomic) IBOutlet UILabel *tagDetail;
@end
