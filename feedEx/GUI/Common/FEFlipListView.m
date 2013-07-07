//
//  FEFlipImageListView.m
//  feedEx
//
//  Created by csnguyen on 7/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFlipListView.h"
@interface FEFlipListView()
@property (nonatomic, strong) UIView *frontView;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeRecognizer;
@end

@implementation FEFlipListView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return  self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeFrom:)];
    self.leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeFrom:)];
    self.rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:self.leftSwipeRecognizer];
    [self addGestureRecognizer:self.rightSwipeRecognizer];
}
- (void)dealloc {
    [self removeGestureRecognizer:self.leftSwipeRecognizer];
    [self removeGestureRecognizer:self.rightSwipeRecognizer];
}
#pragma mark - abstract functions
- (UIView*)getViewAtIndex:(NSUInteger)index {
    // have to implement at inherited class
    return nil;
}
#pragma mark - setter getter
- (void)setDatasource:(NSArray *)datasource withSelectedIndex:(NSUInteger)index{
    _datasource = datasource;
    [self.frontView removeFromSuperview];
    self.frontView = nil;
    if (self.datasource.count > 0 && index < self.datasource.count) {
        self.currentViewIndex = index;
        self.frontView = [self getViewAtIndex:index];
        [self addSubview:self.frontView];
    }
}
#pragma mark - event handler
-(void)handleLeftSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self handleSwipeFrom:recognizer];
}
-(void)handleRightSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    [self handleSwipeFrom:recognizer];
}
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    UIView *nextView;
    UIViewAnimationOptions animationOpt;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        animationOpt = UIViewAnimationOptionTransitionFlipFromLeft;
        if (self.currentViewIndex != 0) {
            self.currentViewIndex--;
            nextView = [self getViewAtIndex:self.currentViewIndex];
        }
    }
    else {
        animationOpt = UIViewAnimationOptionTransitionFlipFromRight;
        if (self.currentViewIndex < (self.datasource.count - 1)) {
            self.currentViewIndex++;
            nextView = [self getViewAtIndex:self.currentViewIndex];
        }
    }
    if (nextView == nil) {
        return;
    }
    
    [UIView transitionWithView:self
                      duration:0.5
                       options:animationOpt
                    animations: ^{
                        [self.frontView removeFromSuperview];
                        self.frontView = nextView;
                        [self addSubview:self.frontView];
                    }
                    completion:^(BOOL finished) {
                    }];
}
@end
