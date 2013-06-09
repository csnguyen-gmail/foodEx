//
//  FENextInputAccessoryView.m
//  feedEx
//
//  Created by csnguyen on 5/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FECustomInputAccessoryView.h"
@interface FECustomInputAccessoryView()

@end

@implementation FECustomInputAccessoryView
- (id)initWithButtons:(NSArray *)buttons {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 40)];
    if (self) {
        [self setupToolBarWithButtons:buttons];
    }
    return self;
}
- (id)initWithButtons:(NSArray *)buttons andSuggestionWord:(NSArray *)words {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 80)];
    if (self) {
        [self setupToolBarWithButtons:buttons];
        self.suggestionWords = words;
    }
    return self;
}
- (void)setupToolBarWithButtons:(NSArray*)buttons {
    NSMutableArray *buttonList = [[NSMutableArray alloc] init];
    // set up accesorr view content
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    toolBar.barStyle=UIBarStyleBlack;
    toolBar.translucent = YES;
    // space
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil action:nil];
    [buttonList addObject:flexSpace];
    // additinal button
    if (buttons) {
        [buttonList addObjectsFromArray:buttons];
    }
    [toolBar setItems:buttonList];
    [self addSubview:toolBar];
}

- (void)setSuggestionWords:(NSArray *)suggestionWords {
    // TODO
}

@end
