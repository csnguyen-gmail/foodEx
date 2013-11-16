//
//  FEImagePickerEditCell.h
//  NewImagePicker
//
//  Created by csnguyen on 11/14/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEImagePickerEditCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *effectImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
- (void)setSelectedStyle:(BOOL)selected;
@end
