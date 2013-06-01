//
//  FENextInputAccessoryView.m
//  feedEx
//
//  Created by csnguyen on 5/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FENextInputAccessoryView.h"
@interface FENextInputAccessoryView()
@property (nonatomic, weak) UIView *nextView;
@end

@implementation FENextInputAccessoryView
- (id)initWithNextTextField:(UIView*)nextView additionalButtons:(NSArray*)buttons{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 40)];
    if (self) {
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
        // next button
        if (nextView) {
            self.nextView = nextView;
            UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self action:@selector(nextButtonTapped:)];
            nextButton.tintColor = [UIColor blackColor];
            [buttonList addObject:nextButton];
        }
        
        [toolBar setItems:buttonList];
        [self addSubview:toolBar];
    }
    return self;
}
- (void)nextButtonTapped:(id)sender
{
    [self.nextView becomeFirstResponder];
}

@end
