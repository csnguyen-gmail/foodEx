//
//  FEVerticalResizeControllView.m
//  feedEx
//
//  Created by csnguyen on 5/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEVerticalResizeControllView.h"
#import "NSString+Extension.h"
@interface FEVerticalResizeControllView() {
    float _beginY;
    double _beginTime;
    BOOL _duringTap;
}
@property (nonatomic, weak) UIView *upperView;
@property (nonatomic, weak) UIView *lowerView;
@end
@implementation FEVerticalResizeControllView
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (_duringTap) {
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    }
    else {
        CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    }
    
    NSString *separateString = @"・・・";
    [separateString drawCenteredInRect:rect withFont:[UIFont systemFontOfSize:25]];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _beginY = point.y;
    _beginTime = CACurrentMediaTime();
    _duringTap = YES;
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (_beginY != point.y) {
        float delta = point.y - _beginY;
        [self.delegate verticalResizeControllerDidChanged:delta];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (CACurrentMediaTime() - _beginTime <= 0.2f) {
        [self.delegate verticalResizeControllerDidTapped];
    }
    _duringTap = NO;
    [self setNeedsDisplay];
}
@end
