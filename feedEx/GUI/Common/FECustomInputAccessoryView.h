//
//  FENextInputAccessoryView.h
//  feedEx
//
//  Created by csnguyen on 5/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FECustomInputAccessoryViewDelegate<NSObject>
- (void)suggestionWordTapped:(NSString*)word;
@end

@interface FECustomInputAccessoryView : UIView
@property (nonatomic, strong) NSArray *suggestionWords; // array of NSString
@property (nonatomic, strong) NSString *filterWord;
@property (nonatomic, weak) id<FECustomInputAccessoryViewDelegate> delegate;

- (id)initWithButtons:(NSArray*)buttons;
- (id)initWithButtons:(NSArray*)buttons andSuggestionWord:(NSArray*)words;
@end
