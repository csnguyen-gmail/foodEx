//
//  FEImagePicker.m
//  NewImagePicker
//
//  Created by csnguyen on 11/15/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePicker.h"
#import "FEImagePickerCameraVC.h"
#import "FEImagePickerPhotoVC.h"
#import "FEImagePickerEditVC.h"

@interface FEImagePicker()<FEImagePickerCameraDelegate, FEImagePickerPhotoDelegate, FEImagePickerEditDelegate>
@property (nonatomic, weak) UIViewController* parentVC;
@end
@implementation FEImagePicker
- (void)startPickupWithParentViewController:(UIViewController *)vc {
    self.parentVC = vc;
    [self showCamera];
}
- (void)showCamera {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FEImagePicker" bundle:[NSBundle mainBundle]];
    FEImagePickerCameraVC *vc = [storyBoard instantiateViewControllerWithIdentifier:@"imagePickerCameraVC"];
    vc.delegate = self;
    [self.parentVC presentViewController:vc animated:YES completion:nil];
}
- (void)showPhoto {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FEImagePicker" bundle:[NSBundle mainBundle]];
    FEImagePickerPhotoVC *vc = [storyBoard instantiateViewControllerWithIdentifier:@"imagePickerPhotoVC"];
    vc.delegate = self;
    [self.parentVC presentViewController:vc animated:YES completion:nil];
}
- (void)showEditWithImage:(UIImage*)image {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FEImagePicker" bundle:[NSBundle mainBundle]];
    FEImagePickerEditVC *vc = [storyBoard instantiateViewControllerWithIdentifier:@"imagePickerEditVC"];
    vc.delegate = self;
    vc.image = image;
    [self.parentVC presentViewController:vc animated:NO completion:nil];
}
#pragma mark - FEImagePicker delegate
- (void)imagePickerCamera:(FEImagePickerCameraVC *)cameraVC didFinishWithImage:(UIImage *)image {
    [cameraVC dismissViewControllerAnimated:(image==nil) completion:^{
        if (image) {
            [self showEditWithImage:image];
        }
        else {
            [self.delegate imagePickerDidFinishWithImage:nil];
        }
    }];
}
- (void)imagePickerCameraSwithToPhoto:(FEImagePickerCameraVC *)cameraVC {
    [cameraVC dismissViewControllerAnimated:NO completion:^{
        [self showPhoto];
    }];
}
- (void)imagePickerPhoto:(FEImagePickerPhotoVC *)photoVC didFinishWithImage:(UIImage *)image {
    [photoVC dismissViewControllerAnimated:(image==nil) completion:^{
        if (image) {
            [self showEditWithImage:image];
        }
        else {
            [self.delegate imagePickerDidFinishWithImage:image];
        }
    }];
}
- (void)imagePickerPhotoSwithToCamera:(FEImagePickerPhotoVC *)photoVC {
    [photoVC dismissViewControllerAnimated:NO completion:^{
        [self showCamera];
    }];
}
- (void)imagePickerEdit:(FEImagePickerEditVC *)editVC didFinishWithImage:(UIImage *)image {
    [editVC dismissViewControllerAnimated:YES completion:^{
        [self.delegate imagePickerDidFinishWithImage:image];
    }];
}
- (void)imagePickerEditRetake:(FEImagePickerEditVC *)editVC {
    [editVC dismissViewControllerAnimated:NO completion:^{
        [self showCamera];
    }];
}
@end
