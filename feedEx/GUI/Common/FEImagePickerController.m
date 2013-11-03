//
//  FEImagePickerController.m
//  TestCamera
//
//  Created by csnguyen on 10/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerController.h"

@interface FEImagePickerController ()
@end

@implementation FEImagePickerController
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    // TODO: this may call multi time incorrectly
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self addPhotoButton];
    }
}
- (void)switchToPhoto {
    [self.imagePickerDelegate switchToPhoto];
}
- (void)switchToCamera {
    [self.imagePickerDelegate switchToCamera];
}

- (void)addPhotoButton {
//    [self inspectView:self.view depth:0 path:@""];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(245, 34, 62, 33);
    [button setTitle:@"Photo" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [button setTitleColor:[UIColor colorWithRed:0.173 green:0.176 blue:0.176 alpha:1] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButton"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButtonPressed"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(switchToPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *shutterButtonView = [self findShutterButtonObj:self.view];
    [[shutterButtonView superview] addSubview:button];
}
- (UIView*)findShutterButtonObj:(UIView*)rootView {
    if ([NSStringFromClass([rootView class]) isEqualToString:@"PLCameraLargeShutterButton"]) {
        return  rootView;
    }
    for (UIView *subView in rootView.subviews) {
        UIView* retView = [self findShutterButtonObj:subView];
        if (retView != nil) {
            return retView;
        }
    }
    return nil;
}
//============================================================================================
// for debug only
-(NSString *)stringPad:(int)numPad {
	NSMutableString *pad = [NSMutableString stringWithCapacity:1024];
	for (int i=0; i<numPad; i++) {
		[pad appendString:@"  "];
	}
	return pad;
}

-(void)inspectView: (UIView *)theView depth:(int)depth path:(NSString *)path {
	
	if (depth==0) {
		NSLog(@"-------------------- <Start view hierarchy> -------------------");
	}
	
	NSString *pad = [self stringPad:depth];
	
	// print some information about the current view
	//
	NSLog(@"%@.description: %@",pad,[theView description]);
	if ([theView isKindOfClass:[UIImageView class]]) {
		NSLog(@"%@.class: UIImageView",pad);
	} else if ([theView isKindOfClass:[UILabel class]]) {
		NSLog(@"%@.class: UILabel",pad);
		NSLog(@"%@.text: %@",pad,[(UILabel *)theView text]);
	} else if ([theView isKindOfClass:[UIButton class]]) {
		NSLog(@"%@.class: UIButton",pad);
		NSLog(@"%@.title: %@",pad,[(UIButton *)theView titleForState:UIControlStateNormal]);
	}
	NSLog(@"%@.frame: %.0f, %.0f, %.0f, %.0f", pad, theView.frame.origin.x, theView.frame.origin.y,
		   theView.frame.size.width, theView.frame.size.height);
	NSLog(@"%@.subviews: %d",pad, [theView.subviews count]);
	NSLog(@" ");
	
	// gotta love recursion: call this method for all subviews
	//
	for (int i=0; i<[theView.subviews count]; i++) {
		NSString *subPath = [NSString stringWithFormat:@"%@/%d",path,i];
		NSLog(@"%@--subview-- %@",pad,subPath);
		[self inspectView:[theView.subviews objectAtIndex:i]  depth:depth+1 path:subPath];
	}
	
	if (depth==0) {
		NSLog(@"-------------------- </End view hierarchy> -------------------");
	}
}
@end
