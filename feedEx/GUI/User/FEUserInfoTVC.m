//
//  FEUserInfoTVC.m
//  feedEx
//
//  Created by csnguyen on 9/19/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEUserInfoTVC.h"
#import "GKImagePicker.h"
#import "Common.h"

@interface FEUserInfoTVC ()<GKImagePickerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) GKImagePicker *imagePicker;
@end

@implementation FEUserInfoTVC
-(void)viewDidLoad {
    [super viewDidLoad];
    self.textChanged = NO;
    self.imageChanged = NO;
}
- (GKImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[GKImagePicker alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (IBAction)imageTapped:(id)sender {
    [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
}
#pragma mark - UITextFieldDelegate Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.textChanged = YES;
    return YES;
}
#pragma mark - GKImagePicker Delegate Methods
- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    self.imageChanged = YES;
    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    self.originImage = [UIImage imageWithImage:image scaledToSize:NORMAL_SIZE];
    self.thumbnailImage = [UIImage imageWithImage:image scaledToSize:THUMBNAIL_SIZE];
    [self.imageBtn setImage:self.originImage forState:UIControlStateNormal];
}

@end
