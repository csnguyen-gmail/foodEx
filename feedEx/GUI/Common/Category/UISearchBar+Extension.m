//
//  UISearchBar+Extension.m
//  feedEx
//
//  Created by csnguyen on 8/11/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "UISearchBar+Extension.h"

@implementation UISearchBar (Extension)
- (void)setSearchBarReturnKeyType:(UIReturnKeyType)returnKeyType {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            [(UITextField *)subview setReturnKeyType:returnKeyType];
            break;
        }
    }
}
@end
