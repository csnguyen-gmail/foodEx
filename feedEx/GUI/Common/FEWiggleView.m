//
//  FEWiggleView.m
//  feedEx
//
//  Created by csnguyen on 5/19/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEWiggleView.h"
#import <QuartzCore/QuartzCore.h>

@interface FEWiggleView()
@end

@implementation FEWiggleView
- (id)initWithMainView:(UIView *)mainView deleteView:(UIView *)deleteView {
    self = [super init];
    if (self) {
        _mainView = mainView;
        _deleteView = deleteView;
        
        self.frame = _mainView.frame;
        [self addSubview:_mainView];
        
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
        
        self.editMode = NO;
        self.dragMode = NO;
    }
    return self;
}
- (void)setEditMode:(BOOL)editMode {
    _editMode = editMode;
    if (editMode) {
        [self startWiggling];
    }
    else {
        [self stopWiggling];
    }
}
- (void)setDragMode:(BOOL)dragMode {
    _dragMode = dragMode;
    if (dragMode) {
        [self appearDraggable];
    }
    else {
        [self appearNormal];
    }
}
#pragma mark - wiggle effect
- (void)appearDraggable {
    self.layer.opacity = 0.6f;
    [self.layer setValue:@1.25f forKeyPath:@"transform.scale"];
    
}

- (void)appearNormal {
    self.layer.opacity = 1.0f;
    [self.layer setValue:@1.0f forKeyPath:@"transform.scale"];
}

- (void)startWiggling {
    self.deleteView.frame = CGRectMake(5.0f,
                                       5.0f,
                                       self.deleteView.frame.size.width,
                                       self.deleteView.frame.size.height);
    [self addSubview:self.deleteView];
    self.userInteractionEnabled = YES; // this tells the subview it owns the touches inside of it
    
    CAAnimation *rotationAnimation = [self wiggleRotationAnimation];
    [self.layer addAnimation:rotationAnimation forKey:@"wiggleRotation"];    
    CAAnimation *translationYAnimation = [self wiggleTranslationYAnimation];
    [self.layer addAnimation:translationYAnimation forKey:@"wiggleTranslationY"];
}

- (void)stopWiggling {
    [self.deleteView removeFromSuperview];
    self.userInteractionEnabled = NO;
    
    [self.layer removeAnimationForKey:@"wiggleRotation"];
    [self.layer removeAnimationForKey:@"wiggleTranslationY"];
}

- (CAAnimation *)wiggleRotationAnimation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = @[@-0.05f, @0.05f];
    anim.duration = 0.09f + ((arc4random() % 10) * 0.01f); // make it random
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    return anim;
}

- (CAAnimation *)wiggleTranslationYAnimation {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    anim.values = @[@-1.0f, @1.0f];
    anim.duration = 0.07f + ((arc4random() % 10) * 0.01f); // make it random
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    anim.additive = YES;
    return anim;
}

@end
