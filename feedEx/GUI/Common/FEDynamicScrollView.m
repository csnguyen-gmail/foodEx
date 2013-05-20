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
@property (nonatomic, strong) FEWiggleView *draggingWiggleView;
@property (nonatomic, strong) FEWiggleView *emptyWiggleView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, weak) NSTimer *waitForPagingTimer;
@end

@implementation FEDynamicScrollView
- (void)awakeFromNib {
    // add gesture recognizer
     self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:self.longPressGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    // this tells the UIScrollView class to allow touches within subviews
    self.canCancelContentTouches = NO;
}
- (void)setWiggleViews:(NSMutableArray *)wiggleViews {
    _wiggleViews = wiggleViews;
    // add view
    for (FEWiggleView *view in wiggleViews) {
        [self addSubview:view];
    }
    [self rearrangeAllView];
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
- (void)enterDraggingModeForView:(FEWiggleView*)view {
    int index = [self.wiggleViews indexOfObject:view];
    self.emptyWiggleView = [[FEWiggleView alloc] init];
    self.emptyWiggleView.frame = view.frame;
    [self.wiggleViews insertObject:self.emptyWiggleView atIndex:index];
    [self addSubview:self.emptyWiggleView];
    
    self.draggingWiggleView = view;
    self.draggingWiggleView.dragMode = YES;
    [self.wiggleViews removeObject:self.draggingWiggleView];
    [self bringSubviewToFront:self.draggingWiggleView];
}
- (void)exitDraggingMode {
    if (!self.draggingWiggleView) {
        return;
    }
    [UIView animateWithDuration:0.2f
                     animations:^{
                         int index = [self.wiggleViews indexOfObject:self.emptyWiggleView];
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
}
- (void)setWaitForPagingTimer:(NSTimer *)waitForPagingTimer {
    [_waitForPagingTimer invalidate];
    _waitForPagingTimer = waitForPagingTimer;
}
- (void) rearrangeAllView {
    // effect
    [UIView animateWithDuration:0.2f
                     animations:^{
                         NSUInteger widthOfContentView = 0;
                         for (FEWiggleView *view in self.wiggleViews) {
                             float viewWidth = view.frame.size.width;
                             float viewHeight = view.frame.size.height;
                             view.frame = CGRectMake(widthOfContentView, 0, viewWidth, viewHeight);
                             // add to control
                             widthOfContentView += viewWidth + DYNAMIC_SCROLLVIEW_PADDING;
                         }
                         self.contentSize = CGSizeMake(widthOfContentView, self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                     }];
}
#pragma mark - handle update
- (void)addView:(FEWiggleView *)wiggleView atIndex:(int)index {
    wiggleView.editMode = self.editMode;
    [self addSubview:wiggleView];
    [self.wiggleViews insertObject:wiggleView atIndex:index];
    [self rearrangeAllView];
    [self scrollRectToVisible:wiggleView.frame animated:YES];
}
- (void)removeView:(FEWiggleView*)wiggleImageView {
    [wiggleImageView removeFromSuperview];
    [self.wiggleViews removeObject:wiggleImageView];
    [self rearrangeAllView];
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
    
    float midXofDraggingView = self.draggingWiggleView.frame.origin.x + self.draggingWiggleView.frame.size.width / 2;
    // find interact view
    for (FEWiggleView *view in self.wiggleViews) {
        if (view != self.emptyWiggleView) {
            if ((view.frame.origin.x < midXofDraggingView )
                && (view.frame.origin.x + view.frame.size.width) > midXofDraggingView) {
                int index = [self.wiggleViews indexOfObject:self.emptyWiggleView];
                [self.wiggleViews removeObject:view];
                [self.wiggleViews insertObject:view atIndex:index];
                [self rearrangeAllView];
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
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (self.editMode) {
                [self exitDraggingMode];
                self.waitForPagingTimer = nil;
            }
            self.editMode = YES;
            [self removeGestureRecognizer:self.longPressGesture];
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
    [self exitDraggingMode];
    CGPoint location = [recognizer locationInView:self];
    for (FEWiggleView *wiggleView in self.wiggleViews) {
        if (CGRectContainsPoint(wiggleView.deleteView.frame, [self convertPoint:location toView:wiggleView.deleteView])) {
            [self removeView:wiggleView];
            break;
        }
    }
}

@end
