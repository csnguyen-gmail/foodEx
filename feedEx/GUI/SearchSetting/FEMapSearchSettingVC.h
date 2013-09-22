//
//  FEMapSearchSettingVC.h
//  feedEx
//
//  Created by csnguyen on 9/21/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FESearchSettingInfo.h"
@protocol FEMapSearchSettingVCDelegate<NSObject>
- (void)didFinishSetting:(FEMapSearchPlaceSettingInfo*)searchSetting hasModification:(BOOL)hasModification;
@end

@interface FEMapSearchSettingVC : UIViewController
@property (weak, nonatomic) id<FEMapSearchSettingVCDelegate> delegate;
@end
