//
//  FEImagePickerGridView.m
//  NewImagePicker
//
//  Created by csnguyen on 11/7/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerGridView.h"

@implementation FEImagePickerGridView
- (void)setNumberOfLine:(NSUInteger)numberOfLine {
    _numberOfLine = numberOfLine;
    [self setNeedsDisplay];
}
- (void)setHiddenGrid:(BOOL)hiddenGrid {
    _hiddenGrid = hiddenGrid;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    if (self.hiddenGrid) {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0 alpha:0.7] CGColor]);
    CGContextSetLineWidth(context, 3.0);
    CGContextStrokeRect(context, rect);
    CGContextSetLineWidth(context, 1.0);
    CGFloat horDist = self.frame.size.width / self.numberOfLine;
    CGFloat verDist = self.frame.size.height / self.numberOfLine;
    CGFloat nextX = horDist;
    CGFloat nextY = verDist;
    for (int i = 1; i < self.numberOfLine; i++) {
        // vertical
        CGContextMoveToPoint(context, nextX, 0.0);
        CGContextAddLineToPoint(context, nextX, rect.size.height);
        CGContextStrokePath(context);
        nextX += horDist;
        // horizon
        CGContextMoveToPoint(context, 0.0, nextY);
        CGContextAddLineToPoint(context, rect.size.width, nextY);
        CGContextStrokePath(context);
        nextY += verDist;
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:touch.view];
    [self.delegate tapAtPoint:touchPoint];
}
@end
