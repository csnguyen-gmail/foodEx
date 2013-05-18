//
//  FEWiggleImageView.m
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEWiggleImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface FEWiggleImageView()
@property (nonatomic, strong) UITapGestureRecognizer *additionViewTapGesture;
@end

@implementation FEWiggleImageView
- (void)setRoundedCorner:(BOOL)roundedCorner {
    _roundedCorner = roundedCorner;
    if (roundedCorner) {
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
    }
    else {
        self.layer.cornerRadius = 0.0f;
        self.layer.masksToBounds = NO;
    }
}

- (UITapGestureRecognizer *)additionViewTapGesture {
    if (!_additionViewTapGesture) {
        _additionViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTapGesture:)];
    }
    return _additionViewTapGesture;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    //    CGPoint location = [recognizer locationInView:self];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            [self.delegate tappedToAdditionalView:self];
            break;
        default:
            break;
    }
}


#pragma mark - wiggle effect
- (void)appearDraggable {
    self.layer.opacity = 0.6f;
    [self setValue:@1.25f forKeyPath:@"transform.scale"];
    
}

- (void)appearNormal {
    self.layer.opacity = 1.0f;
    [self setValue:@1.0f forKeyPath:@"transform.scale"];
}

- (void)startWiggling {
    if (self.additionalView) {
        self.additionalView.frame = CGRectMake(5.0f, 5.0f,
                                               self.additionalView.frame.size.width,
                                               self.additionalView.frame.size.height);
        [self.additionalView addGestureRecognizer:self.additionViewTapGesture];
        self.additionalView.userInteractionEnabled = YES; // image view can not recoginize gesture unless this property is YES
        [self addSubview:self.additionalView];
        self.userInteractionEnabled = YES;
    }
    CAAnimation *rotationAnimation = [self wiggleRotationAnimation];
    [self.layer addAnimation:rotationAnimation forKey:@"wiggleRotation"];
    
    CAAnimation *translationYAnimation = [self wiggleTranslationYAnimation];
    [self.layer addAnimation:translationYAnimation forKey:@"wiggleTranslationY"];
}

- (void)stopWiggling {
    if (self.additionalView) {
        [self.additionalView removeGestureRecognizer:self.additionViewTapGesture];
        self.additionalView.userInteractionEnabled = NO;
        [self.additionalView removeFromSuperview];
        self.userInteractionEnabled = NO;
    }
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
