//
//  FESearchTagVC.h
//  feedEx
//
//  Created by csnguyen on 6/24/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FESearchTagVCDelegate <NSObject>
- (void)didSelectTags:(NSArray*)selectedTags;
@end

@interface FESearchTagVC : UIViewController
@property (nonatomic, weak) id<FESearchTagVCDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *selectedTags; // of NSString
@end
