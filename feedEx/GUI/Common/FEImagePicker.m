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
    self.parentVC = parentVC;
    [self showImagePicker];
}
#pragma mark - setter getter
- (FEImagePickerController*)createImagePicker {
    FEImagePickerController *imagePicker = [[FEImagePickerController alloc] init];
    imagePicker.sourceType = self.sourceType;
    imagePicker.delegate = self;
    imagePicker.wantsFullScreenLayout = YES;
    imagePicker.imagePickerDelegate = self;
    return imagePicker;
}
- (int)sourceType {
    if (_sourceType == -1) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        id object = [prefs objectForKey:IMAGE_PICKER_SOURCE_TYPE];
        if (object == nil) {
            _sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else {
            _sourceType = [object intValue];
        }
    }
    return _sourceType;
}

- (void)setSourceType:(NSInteger)sourceType {
    _sourceType = sourceType;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:sourceType forKey:IMAGE_PICKER_SOURCE_TYPE];
    [prefs synchronize];
}
- (void)showImagePicker {
    if (self.imagePickerController != nil) {
        [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
            self.imagePickerController = [self createImagePicker];
            [self.parentVC presentViewController:self.imagePickerController animated:YES completion:nil];
        }];
    }
    else {
        self.imagePickerController = [self createImagePicker];
        [self.parentVC presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}
- (void)closeImagePicker {
    [self.imagePickerController dismissViewControllerAnimated:NO completion:nil];
    self.imagePickerController= nil;
}
#pragma mark - FEImagePickerVCDelegate
- (void)switchToCamera {
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self showImagePicker];
}
- (void)switchToPhoto {
    self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self showImagePicker];
}
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(switchToCamera)];
    cameraButton.enabled = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    viewController.navigationItem.leftBarButtonItems = @[cameraButton];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self closeImagePicker];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    FEImageEditorVC *imageEditorVC = [storyBoard instantiateViewControllerWithIdentifier:@"ImageEditorVC"];
    imageEditorVC.checkBounds = YES;
    imageEditorVC.sourceImage = info[UIImagePickerControllerOriginalImage];
    [imageEditorVC reset:NO];
    __weak FEImageEditorVC *weakImageEditorVC = imageEditorVC;
    imageEditorVC.doneCallback = ^(UIImage *editedImage, BOOL canceled){
        [weakImageEditorVC dismissViewControllerAnimated:NO completion:^{
            if(!canceled) {
                [self.delegate imagePicker:self pickedImage:editedImage];
                [self closeImagePicker];
            }
            else {
                [self showImagePicker];
            }
        }];
    };
    [self.parentVC presentViewController:imageEditorVC animated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // don't know why have to call dismiss whenrealize this function.
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.delegate imagePickerCancel];
    }];
}

@end
