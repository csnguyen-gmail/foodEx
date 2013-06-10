//
//  FETestViewController.m
//  feedEx
//
//  Created by csnguyen on 6/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETestViewController.h"

@interface FETestViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation FETestViewController
- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"Text change");
    return YES;
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"Focus change");
}
@end
