//
//  FEImageEditorCell.h
//  feedEx
//
//  Created by csnguyen on 11/3/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FEImageEditorCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *effectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
- (void)setSelectedStyle:(BOOL)selected;
@end
