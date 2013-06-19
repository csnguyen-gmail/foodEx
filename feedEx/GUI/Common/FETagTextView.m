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

#pragma mark - event processing
- (void)nextInAccessoryTapped:(UIBarButtonItem*)sender {
    [self.nextTextField becomeFirstResponder];
}
- (void)doneInAccessoryTapped:(UIBarButtonItem*)sender {
    [self resignFirstResponder];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *customInputView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        customInputView.suggestionWords = [self rebuildSuggestionWords:self.tags withSelectedWords:[self buildTagArray]];
        customInputView.filterWord = [self getStringBetweenCommas:self];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if ([self.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *customInputView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        customInputView.filterWord = [self getStringBetweenCommas:textView];
    }
}
//- (void)textViewDidChange:(UITextView *)textView {   // don't using textViewDidChange to prevent it's called before textDidChange of super
- (void)textDidChange:(NSNotification *)notification {
    [super textDidChange:notification];
    if ([self.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *customInputView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        customInputView.suggestionWords = [self rebuildSuggestionWords:self.tags withSelectedWords:[self buildTagArray]];
        customInputView.filterWord = [self getStringBetweenCommas:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self formatText];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfString:@"\n"].length != 0) {
        return NO;
    }
    return  YES;
}
#pragma mark - utility finctions
- (NSMutableArray*)rebuildSuggestionWords:(NSArray*)suggestionWords withSelectedWords:(NSArray*)selectedWords{
    NSMutableArray *newSuggestionWords = [[NSMutableArray alloc] init];
    for (NSString *tag in suggestionWords) {
        if (![selectedWords containsObject:tag]) {
            [newSuggestionWords addObject:tag];
        }
    }
    return newSuggestionWords;
}
- (void)formatText {
    NSMutableArray *tags = [self buildTagArray];
    if (tags == nil) {
        return;
    }
    NSMutableString *formatedText = [[NSMutableString alloc] init];
    for (int i = 0; i < tags.count - 1; i++) {
        [formatedText appendFormat:@"%@, ",tags[i]];
    }
    [formatedText appendFormat:@"%@",tags[tags.count - 1]];
    self.text = formatedText;
}
- (NSMutableArray*)buildTagArray{
    if (self.usingPlaceholder) {
        return nil;
    }
    NSArray *tags = [self.text componentsSeparatedByString:@","];
    NSMutableArray *uniqueTags = [[NSMutableArray alloc] init];
    for (NSString *tag in tags) {
        NSString *strimedTag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![uniqueTags containsObject:strimedTag] && ![strimedTag isEqualToString:@""]) {
            [uniqueTags addObject:strimedTag];
        }
    }
    return uniqueTags;
}
- (NSString*)getStringBetweenCommas:(UITextView*)textView {
    NSString *text = [textView.text substringWithRange:[self getRangeBetweenCommas:textView]];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return text;
}
- (NSRange)getRangeBetweenCommas:(UITextView *)textView {
    if (self.isUsingPlaceholder) {
        return NSMakeRange(0, 0);
    }
    NSRange selectedRange = textView.selectedRange;
    NSString *text = textView.text;
    NSRange startCommaRange = [text rangeOfString:@","
                                          options:(NSCaseInsensitiveSearch|NSBackwardsSearch)
                                            range:NSMakeRange(0, selectedRange.location)];
    NSRange endCommaRange = [text rangeOfString:@","
                                        options:(NSCaseInsensitiveSearch)
                                          range:NSMakeRange(selectedRange.location, (text.length - selectedRange.location))];
    if (startCommaRange.length == 0) {
        startCommaRange.location = 0;
    }
    if (startCommaRange.location != 0) {
        startCommaRange.location += 1;
    }
    if (endCommaRange.length == 0) {
        endCommaRange.location = text.length;
    }
    return NSMakeRange(startCommaRange.location, endCommaRange.location - startCommaRange.location);
}
- (void)suggestionWordTapped:(NSString *)word {
    NSString *text = self.text;
    NSRange range = [self getRangeBetweenCommas:self];
    NSString *replaceString;
    if (self.isUsingPlaceholder || (text.length == (range.location + range.length))) {
        replaceString = [NSString stringWithFormat:@" %@, ", word];
    } else {
        replaceString = [NSString stringWithFormat:@" %@", word];
    }
    text = [text stringByReplacingCharactersInRange:range withString:replaceString];
    self.text = text;
    [self sendCursorToRange:NSMakeRange(range.location + replaceString.length, 0)];
}
- (void)sendCursorToRange:(NSRange)range
{
    [self performSelector:@selector(cursorToBeginning:) withObject:[NSValue valueWithRange:range] afterDelay:0.01];
}

- (void)cursorToBeginning:(NSValue*)rangeValue
{
    super.selectedRange = [rangeValue rangeValue];
}

@end
