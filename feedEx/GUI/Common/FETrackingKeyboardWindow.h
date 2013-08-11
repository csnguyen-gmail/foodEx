//
//  FETrackingKeyboardWindow.h
//  feedEx
//
//  Created by csnguyen on 5/27/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FETrackingKeyboardWindow : UIWindow
- (void)startObservingFirstResponder;
- (void)stopObservingFirstResponder;

@end
