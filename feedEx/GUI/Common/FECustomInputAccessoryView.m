//
//  FENextInputAccessoryView.m
//  feedEx
//
//  Created by csnguyen on 5/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FECustomInputAccessoryView.h"
#define TOOLBAR_HEIGHT 40
#define SCROLL_VIEW_HEIGHT 40
#define WORD_PADDING 1
#define WORD_MARGING 15
@interface FECustomInputAccessoryView()
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation FECustomInputAccessoryView
- (id)initWithButtons:(NSArray *)buttons {
    self = [super initWithFrame:CGRectMake(0, 0, 320, TOOLBAR_HEIGHT)];
    if (self) {
        [self setupToolBarWithButtons:buttons];
    }
    return self;
}
- (id)initWithButtons:(NSArray *)buttons andSuggestionWord:(NSArray *)words {
    self = [super initWithFrame:CGRectMake(0, 0, 320, TOOLBAR_HEIGHT + SCROLL_VIEW_HEIGHT)];
    if (self) {
        [self setupToolBarWithButtons:buttons];
        self.suggestionWords = words;
        self.filterWord = @"";
    }
    return self;
}
- (void)setupToolBarWithButtons:(NSArray*)buttons {
    NSMutableArray *buttonList = [[NSMutableArray alloc] init];
    // set up accesorr view content
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, TOOLBAR_HEIGHT)];
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

- (void)setFilterWord:(NSString *)filterWord {
    _filterWord = filterWord;
    [self.scrollView removeFromSuperview];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, TOOLBAR_HEIGHT, 320, SCROLL_VIEW_HEIGHT)];
    self.scrollView.backgroundColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    
    // filter
    NSMutableArray *filteredWords = [[NSMutableArray alloc] init];
    for (NSString *word in self.suggestionWords) {
        if ([filterWord isEqualToString:@""]) {
            [filteredWords addObject:word];
        }
        else  {
            NSRange range = [word rangeOfString:filterWord];
            if ((range.length > 0) && (range.length != word.length)) {
                [filteredWords addObject:word];
            }
        }
    }
    // build buttons
    float widthContent = 0.0;
    for (NSString *word in filteredWords) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGSize wordSize = [word sizeWithFont:button.titleLabel.font];
        [button setFrame:CGRectMake(widthContent, 0, wordSize.width + WORD_MARGING, SCROLL_VIEW_HEIGHT)];
        [button setBackgroundImage:[UIImage imageNamed:@"gradientBar"] forState:UIControlStateNormal];
        [button setTitle:word forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(wordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        widthContent += button.frame.size.width + WORD_PADDING;
        [self.scrollView addSubview:button];
    }
    self.scrollView.contentSize = CGSizeMake(widthContent, SCROLL_VIEW_HEIGHT);
    [self addSubview:self.scrollView];

}

- (void)wordButtonTapped:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(suggestionWordTapped:)]) {
        [self.delegate suggestionWordTapped:sender.titleLabel.text];
    }
}

@end
