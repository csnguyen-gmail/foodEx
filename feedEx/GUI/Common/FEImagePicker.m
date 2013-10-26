//
//  FEImagePicker.m
//  TestCamera
//
//  Created by csnguyen on 10/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePicker.h"
#import "FEImageEditorVC.h"
@interface FEImagePicker()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, FEImagePickerVCDelegate>
@property (nonatomic) NSInteger sourceType;
@property (nonatomic, weak) UIViewController* parentVC;
@end

#define IMAGE_PICKER_SOURCE_TYPE @"ImagePickerSourceType"
@implementation FEImagePicker
@synthesize sourceType = _sourceType;
- (id)init {
    if (self = [super init]) {
        _sourceType = -1;
        self.cropSize = CGSizeMake(320, 320);
        self.resizeableCropArea = NO;
    }
    return self;

}
- (void)startPickerFrom:(UIViewController *)parentVC {
    [parentVC presentViewController:self.imagePickerController animated:YES completion:nil];
    self.parentVC = parentVC;
}
#pragma mark - setter getter
- (UIImagePickerController *)imagePickerController {
    if (_imagePickerController == nil) {
        _imagePickerController = [[FEImagePickerController alloc] init];
        _imagePickerController.sourceType = self.sourceType;
        _imagePickerController.delegate = self;
        _imagePickerController.wantsFullScreenLayout = NO;
        _imagePickerController.imagePickerDelegate = self;
        _imagePickerController.needModify = YES;
    }
    return _imagePickerController;
}

- (int)sourceType {
    if (_sourceType == -1) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _sourceType = [prefs integerForKey:IMAGE_PICKER_SOURCE_TYPE];
    }
    return _sourceType;
}

- (void)setSourceType:(NSInteger)sourceType {
    _sourceType = sourceType;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:sourceType forKey:IMAGE_PICKER_SOURCE_TYPE];
    [prefs synchronize];
}
#pragma mark - FEImagePickerVCDelegate
- (void)switchToCamera {
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self switchSource];
}
- (void)switchToPhoto {
    self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self switchSource];
}
- (void)switchSource {
    // prevent layou broken in case just switch sourceType
    [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
        self.imagePickerController = nil;
        [self.parentVC presentViewController:self.imagePickerController animated:YES completion:nil];
    }];
}
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(switchToCamera)];
    viewController.navigationItem.leftBarButtonItems = @[cameraButton];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.imagePickerController.needModify = NO;
    FEImageEditorVC *imageEditorVC = [[FEImageEditorVC alloc] initWithNibName:@"FEImageEditorVC" bundle:nil];
    imageEditorVC.checkBounds = YES;
    imageEditorVC.sourceImage = info[UIImagePickerControllerOriginalImage];
    [imageEditorVC reset:NO];
    imageEditorVC.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        [picker popViewControllerAnimated:YES];
        [picker setNavigationBarHidden:NO animated:YES];
        if(!canceled) {
            if ([self.delegate respondsToSelector:@selector(imagePicker:pickedImage:)]) {
                [self.delegate imagePicker:self pickedImage:editedImage];
            }
            [picker dismissViewControllerAnimated:NO completion:nil];
        }
        else {
            self.imagePickerController.needModify = YES;
        }
    };
    [picker pushViewController:imageEditorVC animated:YES];
    [picker setNavigationBarHidden:YES animated:NO];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // don't know why have to call dismiss whenrealize this function.
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.delegate imagePickerCancel];
    }];
}

@end
