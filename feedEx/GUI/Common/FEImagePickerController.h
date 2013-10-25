//
//  FEImagePickerController.h
//  TestCamera
//
//  Created by csnguyen on 10/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FEImagePickerVCDelegate <NSObject>
- (void)switchToPhoto;
- (void)switchToCamera;
@end

@interface FEImagePickerController : UIImagePickerController
@property (nonatomic, weak) id<FEImagePickerVCDelegate> imagePickerDelegate;
@property (nonatomic) BOOL needModify;
@end
