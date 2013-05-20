//
//  FEDynamicScrollView.m
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEDynamicScrollView.h"
#define DYNAMIC_SCROLLVIEW_PADDING 5

@interface FEDynamicScrollView()
@property (nonatomic) float beginDraggingX;
@property (nonatomic, weak) FEWiggleView *draggingWiggleView;
@property (nonatomic, weak) NSTimer *waitForPagingTimer;
@end

@implementation FEDynamicScrollView
- (void)awakeFromNib {
    // add gesture recognizer
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:longPressGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    // this tells the UIScrollView class to allow touches within subviews
    self.canCancelContentTouches = NO;
}
- (void)setWiggleViews:(NSMutableArray *)wiggleViews {
    _wiggleViews = wiggleViews;
    // arrange images
    NSUInteger widthOfContentView = 0;
    for (FEWiggleView *view in wiggleViews) {
        float viewWidth = view.frame.size.width;
        float viewHeight = view.frame.size.height;
        view.frame = CGRectMake(widthOfContentView, 0, viewWidth, viewHeight);
        // add to control
        widthOfContentView += viewWidth + DYNAMIC_SCROLLVIEW_PADDING;
        [self addSubview:view];
    }
    self.contentSize = CGSizeMake(widthOfContentView, self.frame.size.height);
}

- (void)setEditMode:(BOOL)editMode {
    _editMode = editMode;
    for (FEWiggleView *wiggleView in self.wiggleViews) {
        wiggleView.editMode = editMode;
    }
}
- (void)setDraggingWiggleView:(FEWiggleView *)draggingWiggleView {
    if (draggingWiggleView == nil) {
        _draggingWiggleView.dragMode = NO;
    }
    else {
        draggingWiggleView.dragMode = YES;
    }
    _draggingWiggleView = draggingWiggleView;
}
- (void)setWaitForPagingTimer:(NSTimer *)waitForPagingTimer {
    [_waitForPagingTimer invalidate];
    _waitForPagingTimer = waitForPagingTimer;
}

#pragma mark - handle update
- (void)addView:(FEWiggleView *)wiggleView atIndex:(int)index {
    if (index > self.wiggleViews.count) {
        return;
    }
    // set up wiggle image view
    float viewWidth = wiggleView.frame.size.width;
    float viewHeight = wiggleView.frame.size.height;
    float delta = viewWidth + DYNAMIC_SCROLLVIEW_PADDING;
    float x;
    // insert first
    if (self.wiggleViews.count == 0) {
        x = 0;
    }
    // insert last
    else if (self.wiggleViews.count == index){
        x = self.contentSize.width;
    }
    // insert at middle
    else {
        x = [self.wiggleViews[index] frame].origin.x;
    }
    wiggleView.alpha = 0.0f;
    wiggleView.frame = CGRectMake(x, 0, 0, 0);
    wiggleView.editMode = self.editMode;
    // add to control
    [self addSubview:wiggleView];
    [self setContentOffset:CGPointMake(x, 0) animated:YES];
    
    // effect
    [UIView animateWithDuration:0.2f
                     animations:^{
                         // show wiggle view
                         wiggleView.alpha = 1.0f;
                         wiggleView.frame = CGRectMake(x, 0, viewWidth, viewHeight);
                         // re-arrange right views
                         for (int i = index; i < self.wiggleViews.count; i++) {
                             FEWiggleView *view = self.wiggleViews[i];
                             view.frame = CGRectMake(view.frame.origin.x + delta ,
                                                     view.frame.origin.y,
                                                     view.frame.size.width,
                                                     view.frame.size.height);
                         }
                     }
                     completion:^(BOOL finished) {
                         [self.wiggleViews insertObject:wiggleView atIndex:index];
                         self.contentSize = CGSizeMake(self.contentSize.width + viewWidth + DYNAMIC_SCROLLVIEW_PADDING, self.contentSize.height);
                     }];
}
- (void)removeView:(FEWiggleView*)wiggleImageView {
    float delta = wiggleImageView.frame.size.width + DYNAMIC_SCROLLVIEW_PADDING;
    // effect
    [UIView animateWithDuration:0.2f
                     animations:^{
                         // hide wiggle view
                         wiggleImageView.alpha = 0.0f;
                         wiggleImageView.frame = CGRectMake(wiggleImageView.frame.origin.x,wiggleImageView.frame.origin.y,0,0);
                         // re-arrange right views
                         int index = [self.wiggleViews indexOfObject:wiggleImageView];
                         for (int i = index + 1; i < self.wiggleViews.count; i++) {
                             FEWiggleView *view = self.wiggleViews[i];
                             view.frame = CGRectMake(view.frame.origin.x - delta ,
                                                     view.frame.origin.y,
                                                     view.frame.size.width,
                                                     view.frame.size.height);
                         }
                     }
                     completion:^(BOOL finished) {
                         self.contentSize = CGSizeMake(self.contentSize.width - delta, self.contentSize.height);
                         [wiggleImageView removeFromSuperview];
                         [self.wiggleViews removeObject:wiggleImageView];
                     }];
}
#pragma mark - handle dragging
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.editMode) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    for (FEWiggleView *view in self.wiggleViews) {
        if (CGRectContainsPoint(view.frame, location)) {
            self.draggingWiggleView = view;
            [self bringSubviewToFront:self.draggingWiggleView];
            break;
        }
    }
    self.beginDraggingX = location.x;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.editMode) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    float delta = location.x - self.beginDraggingX;
    self.draggingWiggleView.frame = CGRectMake(self.draggingWiggleView.frame.origin.x + delta,
                                               self.draggingWiggleView.frame.origin.y,
                                               self.draggingWiggleView.frame.size.width,
                                               self.draggingWiggleView.frame.size.height);
    
    self.beginDraggingX = location.x;
    
    CGRect rectInSuperView = [self convertRect:self.draggingWiggleView.frame toView:self.superview];
    // touch to left edge
    if (rectInSuperView.origin.x < 0) {
        if (!self.waitForPagingTimer) {
            NSDictionary *userInfo = @{@"isLeft":@(YES)};
            self.waitForPagingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                       target:self
                                                                     selector:@selector(handleTimer:)
                                                                     userInfo: userInfo
                                                                      repeats:YES];
        }
    }
    // touch to right edge
    else if (rectInSuperView.origin.x + rectInSuperView.size.width > self.frame.size.width) {
        if (!self.waitForPagingTimer) {
            NSDictionary *userInfo = @{@"isLeft":@(NO)};
            self.waitForPagingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                       target:self
                                                                     selector:@selector(handleTimer:)
                                                                     userInfo:userInfo
                                                                      repeats:YES];
        }
    }
    // not touch edge
    else {
        self.waitForPagingTimer = nil;
    }
}
- (void)handleTimer:(NSTimer*)timer {
    BOOL isLeft = [[[timer userInfo] objectForKey:@"isLeft"] boolValue];
    float newContentX;
    if (isLeft) {
        // scroll view to left edge
        newContentX = self.contentOffset.x - self.frame.size.width;
        if (newContentX < 0) {
            newContentX = 0;
        }
    }
    else {
        // scroll view to right edge
        newContentX = self.contentOffset.x + self.frame.size.width;
        if (newContentX + self.frame.size.width > self.contentSize.width) {
            newContentX = self.contentSize.width - self.frame.size.width;
        }
    }
    
    float delta = newContentX - self.contentOffset.x;
    [self setContentOffset:CGPointMake(newContentX, self.contentOffset.y) animated:YES];
    self.beginDraggingX += delta;
    self.draggingWiggleView.frame = CGRectMake(self.draggingWiggleView.frame.origin.x + delta,
                                               self.draggingWiggleView.frame.origin.y,
                                               self.draggingWiggleView.frame.size.width,
                                               self.draggingWiggleView.frame.size.height);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.editMode) {
        return;
    }
    self.draggingWiggleView = nil;
    self.waitForPagingTimer = nil;
}
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.editMode = !self.editMode;
            self.draggingWiggleView = nil;
            self.waitForPagingTimer = nil;
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
}
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    if (!self.editMode) {
        return;
    }
    CGPoint location = [recognizer locationInView:self];
    for (FEWiggleView *wiggleView in self.wiggleViews) {
        if (CGRectContainsPoint(wiggleView.deleteView.frame, [self convertPoint:location toView:wiggleView.deleteView])) {
            [self removeView:wiggleView];
            break;
        }
    }
}

@end
