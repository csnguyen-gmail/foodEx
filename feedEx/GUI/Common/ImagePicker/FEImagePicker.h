//
//  FEImagePicker.h
//  NewImagePicker
//
//  Created by csnguyen on 11/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FEImagePickerDelegate <NSObject>
- (void)imagePickerDidFinishWithImage:(UIImage*)image;
@end

@interface FEImagePicker : NSObject
@property (nonatomic, weak) id<FEImagePickerDelegate> delegate;
- (void)startPickupWithParentViewController:(UIViewController*)vc;
@end
