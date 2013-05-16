//
//  FEVerticalResizeControllView.m
//  feedEx
//
//  Created by csnguyen on 5/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEVerticalResizeControllView.h"
@interface FEVerticalResizeControllView() {
    float beginY;
}
@property (nonatomic, weak) UIView *upperView;
@property (nonatomic, weak) UIView *lowerView;
@end
@implementation FEVerticalResizeControllView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    NSString *separateString = @"・・・";
    [separateString drawInRect:CGRectMake(0, -6, rect.size.width, rect.size.height)
                      withFont:[UIFont systemFontOfSize:25]
                 lineBreakMode:NSLineBreakByCharWrapping
                     alignment:NSTextAlignmentCenter];

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    beginY = point.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (beginY != point.y) {
        float delta = point.y - beginY;
        [self.delegate verticalResizeControllerDidChanged:delta];
    }
}
@end
