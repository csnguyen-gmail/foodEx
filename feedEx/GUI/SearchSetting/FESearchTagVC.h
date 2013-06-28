//
//  FESearchTagVC.h
//  feedEx
//
//  Created by csnguyen on 6/24/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FESearchTagVCDelegate <NSObject>
- (void)didSelectTags:(NSArray*)selectedStringTags;
@end

@interface FESearchTagVC : UIViewController
@property (nonatomic, weak) id<FESearchTagVCDelegate> delegate;

- (void)loadTagWithTagType:(NSNumber*)tagType andSelectedTags:(NSArray*)selectTags;
@end
