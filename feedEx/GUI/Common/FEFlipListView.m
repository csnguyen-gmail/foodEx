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
//@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeRecognizer;
//@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@end

@implementation FEFlipListView
- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
//    self.leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipeFrom:)];
//    self.leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    self.rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipeFrom:)];
//    self.rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:self.leftSwipeRecognizer];
//    [self addGestureRecognizer:self.rightSwipeRecognizer];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self addGestureRecognizer:self.tapRecognizer];
}
- (void)dealloc {
//    [self removeGestureRecognizer:self.leftSwipeRecognizer];
//    [self removeGestureRecognizer:self.rightSwipeRecognizer];
    [self removeGestureRecognizer:self.tapRecognizer];
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
-(void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.frontView];
    [self handleSwipe:(location.x < (self.frontView.frame.size.width / 2) ? UISwipeGestureRecognizerDirectionLeft : UISwipeGestureRecognizerDirectionRight)];
}
//-(void)handleLeftSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
//    [self handleSwipe:recognizer.direction];
//}
//-(void)handleRightSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
//    [self handleSwipe:recognizer.direction];
//}
-(void)handleSwipe:(UISwipeGestureRecognizerDirection)direction {
    if (self.datasource.count == 0) {
        return;
    }
    UIView *nextView;
    UIViewAnimationOptions animationOpt;
    if (direction == UISwipeGestureRecognizerDirectionRight) {
        animationOpt = UIViewAnimationOptionTransitionFlipFromLeft;
        if (self.currentViewIndex != 0) {
            self.currentViewIndex--;
        }
        else {
            self.currentViewIndex = self.datasource.count - 1;
        }
    }
    else {
        animationOpt = UIViewAnimationOptionTransitionFlipFromRight;
        if (self.currentViewIndex < (self.datasource.count - 1)) {
            self.currentViewIndex++;
        }
        else {
            self.currentViewIndex = 0;
        }
    }
    nextView = [self getViewAtIndex:self.currentViewIndex];
    [UIView transitionWithView:self
                      duration:0.4
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
