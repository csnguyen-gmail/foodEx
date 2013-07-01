//
//  FESearchSettingVC.h
//  feedEx
//
//  Created by csnguyen on 6/22/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FESearchSettingInfo.h"

@protocol FESearchSettingVCDelegate<NSObject>
- (void)didFinishSearchSetting:(FESearchSettingInfo*)searchSetting hasModification:(BOOL)hasModification;
@end

@interface FESearchSettingVC : UIViewController
@property (weak, nonatomic) id<FESearchSettingVCDelegate> delegate;
@end
