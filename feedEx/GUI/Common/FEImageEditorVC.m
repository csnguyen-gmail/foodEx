//
//  FEImageEditorVC.m
//  feedEx
//
//  Created by csnguyen on 10/26/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImageEditorVC.h"
#import "HFImageEditorViewController+Private.h"
@interface FEImageEditorVC ()

@end

@implementation FEImageEditorVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cropRect = CGRectMake(0,0,320,320);
        self.minimumScale = 0.2;
        self.maximumScale = 10;
    }
    return self;
}

- (IBAction)resetTapped:(id)sender {
    self.cropRect = CGRectMake((self.frameView.frame.size.width-320)/2.0f, (self.frameView.frame.size.height-320)/2.0f, 320, 320);
    [self reset:YES];
}

@end
