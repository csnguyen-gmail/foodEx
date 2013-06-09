//
//  FENextInputAccessoryView.h
//  feedEx
//
//  Created by csnguyen on 5/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FECustomInputAccessoryView : UIView
@property (nonatomic, strong) NSArray *suggestionWords; // array of NSString

- (id)initWithButtons:(NSArray*)buttons;
- (id)initWithButtons:(NSArray*)buttons andSuggestionWord:(NSArray*)words;
@end
