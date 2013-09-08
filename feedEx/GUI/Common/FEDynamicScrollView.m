//
//  FEDynamicScrollView.m
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEDynamicScrollView.h"
#define DYNAMIC_SCROLLVIEW_WIDTH_PADDING 5
#define DYNAMIC_SCROLLVIEW_HEIGHT_PADDING  2
#define FIRST_X 1

@interface FEDynamicScrollView() {
    NSUInteger _indexViewBeforeDraging;
}
@property (nonatomic) float beginDraggingX;
@property (nonatomic, strong) FEWiggleView *draggingWiggleView;
@property (nonatomic, strong) FEWiggleView *emptyWiggleView;
@property (nonatomic, weak) NSTimer *waitForPagingTimer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;
@end

@implementation FEDynamicScrollView
@synthesize wiggleViews = _wiggleViews;
- (void)awakeFromNib {
    [self setup];
}
- (void)setup {
    // add gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    // this tells the UIScrollView class to allow touches within subviews
    self.canCancelContentTouches = NO;
    // set up default mode of wiggle view
    self.editMode = NO;
}
- (UILongPressGestureRecognizer *)longGesture {
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    }
    return _longGesture;
}
- (NSMutableArray *)wiggleViews {
    if (!_wiggleViews) {
        _wiggleViews = [[NSMutableArray alloc] init];
    }
    return _wiggleViews;
}
- (void)setWiggleViews:(NSMutableArray *)wiggleViews {
    _wiggleViews = wiggleViews;
    // add view
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    for (FEWiggleView *view in wiggleViews) {
        [self addSubview:view];
    }
    [self rearrangeAllViewWithAnimation:NO];
}

- (void)setEditMode:(BOOL)editMode {
    _editMode = editMode;
    if (editMode) {
        [self removeGestureRecognizer:self.longGesture];
    }
    else {
        [self addGestureRecognizer:self.longGesture];
    }
    
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
- (void)enterDraggingModeForView:(FEWiggleView*)view {
    int index = [self.wiggleViews indexOfObject:view];
    _indexViewBeforeDraging = index;
    self.emptyWiggleView = [[FEWiggleView alloc] init];
    self.emptyWiggleView.frame = view.frame;
    [self.wiggleViews insertObject:self.emptyWiggleView atIndex:index];
    [self addSubview:self.emptyWiggleView];
    
    self.draggingWiggleView = view;
    self.draggingWiggleView.dragMode = YES;
    [self.wiggleViews removeObject:self.draggingWiggleView];
    [self bringSubviewToFront:self.draggingWiggleView];
    [self.dynamicScrollViewDelegate enterDraggingMode];
}
- (void)exitDraggingMode {
    if (!self.draggingWiggleView) {
        return;
    }
    int index = [self.wiggleViews indexOfObject:self.emptyWiggleView];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.wiggleViews insertObject:self.draggingWiggleView atIndex:index];
                         self.draggingWiggleView.dragMode = NO;
                         self.draggingWiggleView.frame = self.emptyWiggleView.frame;
                         self.draggingWiggleView = nil;
                         
                         [self.emptyWiggleView removeFromSuperview];
                         [self.wiggleViews removeObject:self.emptyWiggleView];
                         self.emptyWiggleView = nil;
                     }
                     completion:^(BOOL finished) {
                     }];
    [self.dynamicScrollViewDelegate exitDraggingMode];
    [self.dynamicScrollViewDelegate viewMovedFromIndex:_indexViewBeforeDraging toIndex:index];
}

- (void)setWaitForPagingTimer:(NSTimer *)waitForPagingTimer {
    [_waitForPagingTimer invalidate];
    _waitForPagingTimer = waitForPagingTimer;
}
- (void) rearrangeAllViewWithAnimation:(BOOL)animated {
    // effect
    [UIView animateWithDuration:animated ? 0.2f :0.0f
                     animations:^{
                         NSUInteger widthOfContentView = FIRST_X;
                         for (FEWiggleView *view in self.wiggleViews) {
                             float viewWidth = view.frame.size.width;
                             float viewHeight = view.frame.size.height;
                             view.frame = CGRectMake(widthOfContentView, DYNAMIC_SCROLLVIEW_HEIGHT_PADDING, viewWidth, viewHeight);
                             // add to control
                             widthOfContentView += viewWidth + DYNAMIC_SCROLLVIEW_WIDTH_PADDING;
                         }
                         self.contentSize = CGSizeMake(widthOfContentView, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                     }];
}
#pragma mark - handle update
- (void)addView:(FEWiggleView *)wiggleView atIndex:(int)index {
    wiggleView.frame = CGRectOffset(wiggleView.frame, FIRST_X, DYNAMIC_SCROLLVIEW_HEIGHT_PADDING);
    wiggleView.editMode = self.editMode;
    [self addSubview:wiggleView];
    [self.wiggleViews insertObject:wiggleView atIndex:index];
    [self rearrangeAllViewWithAnimation:YES];
    [self scrollRectToVisible:wiggleView.frame animated:YES];
}
- (void)removeView:(FEWiggleView*)wiggleImageView {
    [self.dynamicScrollViewDelegate removeImageAtIndex:[self.wiggleViews indexOfObject:wiggleImageView]];
    [wiggleImageView removeFromSuperview];
    [self.wiggleViews removeObject:wiggleImageView];
    [self rearrangeAllViewWithAnimation:YES];
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
            [self enterDraggingModeForView:view];
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
    self.draggingWiggleView.frame = CGRectOffset(self.draggingWiggleView.frame, delta, 0);
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
    else if ((self.contentSize.width > self.frame.size.width) && (rectInSuperView.origin.x + rectInSuperView.size.width > self.frame.size.width)) {
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
    
    float midXofDraggingView = self.draggingWiggleView.frame.origin.x + self.draggingWiggleView.frame.size.width / 2;
    // find interact view
    for (FEWiggleView *view in self.wiggleViews) {
        if (view != self.emptyWiggleView) {
            if ((view.frame.origin.x < midXofDraggingView )
                && (view.frame.origin.x + view.frame.size.width) > midXofDraggingView) {
                int index = [self.wiggleViews indexOfObject:self.emptyWiggleView];
                [self.wiggleViews removeObject:view];
                [self.wiggleViews insertObject:view atIndex:index];
                [self rearrangeAllViewWithAnimation:YES];
                break;
            }
        }
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
    self.draggingWiggleView.frame = CGRectOffset(self.draggingWiggleView.frame, delta, 0);
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.editMode) {
        return;
    }
    [self exitDraggingMode];
    self.waitForPagingTimer = nil;
}
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    if (!self.editMode) {
        return;
    }
    [self exitDraggingMode];
    CGPoint location = [recognizer locationInView:self];
    for (FEWiggleView *wiggleView in self.wiggleViews) {
        if (CGRectContainsPoint(wiggleView.deleteView.frame, [self convertPoint:location toView:wiggleView.deleteView])) {
            [self removeView:wiggleView];
            break;
        }
    }
}
- (void)handleLongGesture:(UILongPressGestureRecognizer *)recognizer {
    self.editMode = YES;
    [self.dynamicScrollViewDelegate enterEditMode];
}

@end
