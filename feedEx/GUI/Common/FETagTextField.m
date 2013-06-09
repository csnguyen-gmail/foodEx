//
//  FETagTextField.m
//  feedEx
//
//  Created by csnguyen on 6/10/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETagTextField.h"
@interface FETagTextField(){
    id forwardDelegate;
}
@end

@implementation FETagTextField

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
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                                 target:self action:@selector(buttonInAccessoryTapped:)];
    barButton.tintColor = [UIColor blackColor];
    FECustomInputAccessoryView *customInputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]
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
- (void)setText:(NSString *)text {
    [self textDidChanged:text];
    [super setText:text];
}
#pragma mark - processing function
- (void)buttonInAccessoryTapped:(UIBarButtonItem*)sender {
    [self.nextTextField becomeFirstResponder];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self textDidChanged:newString];
    // TODO: add with comma format
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    // TODO: remove with comma format
    return YES;
}
- (void)suggestionWordTapped:(NSString *)word {
    NSString *originString = self.text;
    NSRange lastCommaRange = [originString rangeOfString:@", " options:NSBackwardsSearch];
    // first word
    if (lastCommaRange.length == 0) {
        self.text = [NSString stringWithFormat:@"%@, ", word];
    }
    // from second word
    else {
        self.text = [NSString stringWithFormat:@"%@, %@, ",[originString substringToIndex:lastCommaRange.location], word];
    }
    // TODO: support curson not last row
}

- (void)textDidChanged:(NSString*)text {
    FECustomInputAccessoryView *inputAccessoryView = (FECustomInputAccessoryView*)self.inputAccessoryView;
    NSString *originString = text;
    NSRange lastCommaRange = [originString rangeOfString:@", " options:NSBackwardsSearch];
    // first word
    if (lastCommaRange.length == 0) {
        inputAccessoryView.filterWord = originString;
    }
    // from second word
    else {
        inputAccessoryView.filterWord = [originString substringFromIndex:lastCommaRange.location + @", ".length];
    }
    // TODO: support curson not last row
}

@end
