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

- (void)awakeFromNib {
    [self setup];
}
#pragma mark - setter getter
- (void)setup {
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                                 target:self action:@selector(nextInAccessoryTapped:)];
    nextButton.tintColor = [UIColor blackColor];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                                                  target:self action:@selector(doneInAccessoryTapped:)];
    UIBarButtonItem *nextTagButton = [[UIBarButtonItem alloc] initWithTitle:@"Next tag" style:UIBarButtonItemStyleDone
                                                                     target:self action:@selector(nextTagTapped:)];
    nextTagButton.tintColor = [UIColor lightGrayColor];
    FECustomInputAccessoryView *customInputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[doneButton, nextTagButton, nextButton]
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
- (void)nextTagTapped:(UIBarButtonItem*)sender {
    if (self.isUsingPlaceholder) {
        return;
    }
    NSString *newStr = [self.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (newStr.length == 0) {
        self.text = @"";
        return;
    }
    NSString *lastChar = [newStr substringFromIndex:newStr.length - 1];
    if ([lastChar isEqualToString:@","]) {
        newStr = [NSString stringWithFormat:@"%@%@", newStr, @" "];
    }
    else {
        newStr = [NSString stringWithFormat:@"%@%@", newStr, @", "];
    }
    self.text = newStr;
    if ([self.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *customInputView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        customInputView.suggestionWords = [self rebuildSuggestionWords:self.tags withSelectedWords:[self buildTagArray]];
        customInputView.filterWord = [self getStringBetweenCommas];
    }
}
- (void)nextInAccessoryTapped:(UIBarButtonItem*)sender {
    [self.nextTextField becomeFirstResponder];
}
- (void)doneInAccessoryTapped:(UIBarButtonItem*)sender {
    [self resignFirstResponder];
}
- (void)didBeginEditing{
    if ([self.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *customInputView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        customInputView.suggestionWords = [self rebuildSuggestionWords:self.tags withSelectedWords:[self buildTagArray]];
        customInputView.filterWord = [self getStringBetweenCommas];
    }
}

- (void)didChangeSelection{
    if ([self.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *customInputView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        customInputView.filterWord = [self getStringBetweenCommas];
    }
}
//- (void)textViewDidChange:(UITextView *)textView {   // don't using textViewDidChange to prevent it's called before textDidChange of super
- (void)textDidChange:(NSNotification *)notification {
    [super textDidChange:notification];
    if ([self.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *customInputView = (FECustomInputAccessoryView*)self.inputAccessoryView;
        customInputView.suggestionWords = [self rebuildSuggestionWords:self.tags withSelectedWords:[self buildTagArray]];
        customInputView.filterWord = [self getStringBetweenCommas];
    }
}

- (void)didEndEditing{
    [self formatText];
}

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
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
- (NSString*)getStringBetweenCommas {
    NSString *text = [self.text substringWithRange:[self getRangeBetweenCommas]];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return text;
}
- (NSRange)getRangeBetweenCommas {
    if (self.isUsingPlaceholder) {
        return NSMakeRange(0, 0);
    }
    NSRange selectedRange = self.selectedRange;
    NSString *text = self.text;
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
    NSRange range = [self getRangeBetweenCommas];
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
