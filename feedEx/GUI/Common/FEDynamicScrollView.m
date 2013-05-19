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
@property (nonatomic, strong) NSMutableArray *wiggleImageViews; // array of FEWiggleImageView
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
- (NSMutableArray *)wiggleImageViews {
    if (!_wiggleImageViews) {
        _wiggleImageViews = [[NSMutableArray alloc] init];
    }
    return _wiggleImageViews;
}
- (void)setImages:(NSMutableArray *)images {
    // setter
    _images = images;
    // arrange images
    NSUInteger widthOfContentView = 0;
    for (UIImage *image in images) {
        // set up wiggle image view
        FEWiggleImageView *imageView = [self createWiggleImageViewFromImage:image];
        float imageWidth = imageView.frame.size.width;
        float imageHeight = imageView.frame.size.height;
        imageView.frame = CGRectMake(widthOfContentView, 0, imageWidth, imageHeight);
        // add to control
        widthOfContentView += imageWidth + DYNAMIC_SCROLLVIEW_PADDING;
        [self addSubview:imageView];
        [self.wiggleImageViews addObject:imageView];
    }
    self.contentSize = CGSizeMake(widthOfContentView, self.frame.size.height);
}

- (FEWiggleImageView*)createWiggleImageViewFromImage:(UIImage*)image {
    FEWiggleImageView *imageView = [[FEWiggleImageView alloc] initWithImage:image];
    imageView.roundedCorner = YES;
    imageView.additionalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]];
    imageView.additionalView.opaque = YES;
    return imageView;
}

- (void)setEditMode:(BOOL)editMode {
    _editMode = editMode;
    if (_editMode) {
        for (FEWiggleImageView *view in self.wiggleImageViews) {
            [view startWiggling];
        }
    }
    else {
        for (FEWiggleImageView *view in self.wiggleImageViews) {
            [view stopWiggling];
        }
    }
}
- (void)addView:(UIImage *)image atIndex:(int)index {
    if (index > self.wiggleImageViews.count) {
        return;
    }
    // set up wiggle image view
    FEWiggleImageView *imageView = [self createWiggleImageViewFromImage:image];
    float imageWidth = imageView.frame.size.width;
    float imageHeight = imageView.frame.size.height;
    float delta = imageWidth + DYNAMIC_SCROLLVIEW_PADDING;
    float x;
    // insert first
    if (self.wiggleImageViews.count == 0) {
        x = 0;
    }
    // insert last
    else if (self.wiggleImageViews.count == index){
        x = self.contentSize.width;
    }
    // insert at middle
    else {
        x = [self.wiggleImageViews[index] frame].origin.x;
    }
    imageView.alpha = 0.0f;
    imageView.frame = CGRectMake(x, 0, 0, 0);
    // add to control
    [self addSubview:imageView];
    [self setContentOffset:CGPointMake(x, 0) animated:YES];
    
    // effect
    [UIView animateWithDuration:0.2f
                     animations:^{
                         // show wiggle view
                         imageView.alpha = 1.0f;
                         imageView.frame = CGRectMake(x, 0, imageWidth, imageHeight);
                         // re-arrange right views
                         for (int i = index; i < self.wiggleImageViews.count; i++) {
                             FEWiggleImageView *view = self.wiggleImageViews[i];
                             view.frame = CGRectMake(view.frame.origin.x + delta ,
                                                     view.frame.origin.y,
                                                     view.frame.size.width,
                                                     view.frame.size.height);
                         }
                     }
                     completion:^(BOOL finished) {
                         if (self.editMode) {
                             [imageView startWiggling];
                         }
                         [self.wiggleImageViews insertObject:imageView atIndex:index];
                         [self.images insertObject:image atIndex:index];
                         self.contentSize = CGSizeMake(self.contentSize.width + imageWidth + DYNAMIC_SCROLLVIEW_PADDING, self.contentSize.height);
                     }];
}
- (void)removeView:(FEWiggleImageView*)wiggleImageView {
    float delta = wiggleImageView.frame.size.width + DYNAMIC_SCROLLVIEW_PADDING;
    // effect
    [UIView animateWithDuration:0.2f
                     animations:^{
                         // hide wiggle view
                         wiggleImageView.alpha = 0.0f;
                         wiggleImageView.frame = CGRectMake(wiggleImageView.frame.origin.x,wiggleImageView.frame.origin.y,0,0);
                         // re-arrange right views
                         int index = [self.wiggleImageViews indexOfObject:wiggleImageView];
                         for (int i = index + 1; i < self.wiggleImageViews.count; i++) {
                             FEWiggleImageView *view = self.wiggleImageViews[i];
                             view.frame = CGRectMake(view.frame.origin.x - delta ,
                                                     view.frame.origin.y,
                                                     view.frame.size.width,
                                                     view.frame.size.height);
                         }
                     }
                     completion:^(BOOL finished) {
                         self.contentSize = CGSizeMake(self.contentSize.width - delta, self.contentSize.height);
                         [wiggleImageView removeFromSuperview];
                         [self.images removeObject:wiggleImageView.image];
                         [self.wiggleImageViews removeObject:wiggleImageView];
                     }];
}
#pragma mark - handle gesture
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"begin");
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"move");
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"end");
}
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.editMode = !self.editMode;
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
    for (FEWiggleImageView *view in self.wiggleImageViews) {
        if (CGRectContainsPoint(view.additionalView.frame, [self convertPoint:location toView:view.additionalView])) {
            [self removeView:view];
            break;
        }
    }
}

@end
