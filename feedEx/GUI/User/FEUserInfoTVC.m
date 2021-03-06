//
//  FEUserInfoTVC.m
//  feedEx
//
//  Created by csnguyen on 9/19/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEUserInfoTVC.h"
#import "FEImagePicker.h"
#import "Common.h"

@interface FEUserInfoTVC ()<FEImagePickerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) FEImagePicker *imagePicker;
@end

@implementation FEUserInfoTVC
-(void)viewDidLoad {
    [super viewDidLoad];
    self.textChanged = NO;
    self.imageChanged = NO;
}
- (FEImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[FEImagePicker alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (IBAction)imageTapped:(id)sender {
    [self.imagePicker startPickupWithParentViewController:self];
}
#pragma mark - FEImagePickerDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.textChanged = YES;
    return YES;
}
#pragma mark - FEImagePickerDelegate
- (void)imagePickerDidFinishWithImage:(UIImage *)image {
    if (image) {
        self.imageChanged = YES;
        self.originImage = [UIImage imageWithImage:image scaledToSize:NORMAL_SIZE];
        self.thumbnailImage = [UIImage imageWithImage:image scaledToSize:THUMBNAIL_SIZE];
        [self.imageBtn setImage:self.originImage forState:UIControlStateNormal];
    }
    
}
@end
