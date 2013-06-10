//
//  FETagTextField.m
//  feedEx
//
//  Created by csnguyen on 6/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETagTextView.h"
@interface FETagTextView(){
    id forwardDelegate;
}
@end

@implementation FETagTextView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        super.delegate = self;
        [self setup];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        super.delegate = self;
        [self setup];
    }
    return self;
}
#pragma mark - setDelegate
// override setDelegate: method in which we store supplied delegate to a variable (forwardDelegate);
- (void) setDelegate:(id)delegate {
    forwardDelegate = delegate;
}
// by overriding respondsToSelector:, forwardInvocation: and methodSignatureForSelector: we either call method on self or forward it to saved forwardDelegate.
- (BOOL) respondsToSelector:(SEL)selector
{
    if ([super respondsToSelector:selector]) {
        return YES;
    } else {
        return [forwardDelegate respondsToSelector:selector];
    }
}

- (void) forwardInvocation:(NSInvocation *)invocation
{
    if ([super respondsToSelector:[invocation selector]]) {
        [super forwardInvocation:invocation];
    } else if ([forwardDelegate respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:forwardDelegate];
    } else {
        [self doesNotRecognizeSelector:[invocation selector]];
    }
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    if (signature) {
        return signature;
    } else {
        return [forwardDelegate methodSignatureForSelector:selector];
    }
}
#pragma mark - setter getter
- (void)setup {
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                                 target:self action:@selector(nextInAccessoryTapped:)];
    nextButton.tintColor = [UIColor blackColor];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                                                  target:self action:@selector(doneInAccessoryTapped:)];
    FECustomInputAccessoryView *customInputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[doneButton, nextButton]
                                                                                             andSuggestionWord:self.tags];
    customInputAccessoryView.delegate = self;
    self.inputAccessoryView = customInputAccessoryView;
}

- (void)setTags:(NSArray *)tags {
    if (!_tags) {
        _tags = tags;
        FECustomInputAccessoryView *inputAccessoryView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        inputAccessoryView.suggestionWords = _tags;
    }
}

#pragma mark - processing function
- (void)nextInAccessoryTapped:(UIBarButtonItem*)sender {
    [self.nextTextField becomeFirstResponder];
}
- (void)doneInAccessoryTapped:(UIBarButtonItem*)sender {
    [self resignFirstResponder];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"focus");
    // TODO
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    // TODO: add with comma format
    NSLog(@"change");
    return YES;
}
- (void)suggestionWordTapped:(NSString *)word {
    // TODO
}
@end
