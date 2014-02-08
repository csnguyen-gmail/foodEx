//
//  FEUserEditVC.m
//  feedEx
//
//  Created by csnguyen on 9/19/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEUserEditVC.h"
#import "FEUserInfoTVC.h"
#import <QuartzCore/QuartzCore.h>
#import "User+Extension.h"
#import "AbstractInfo+Extension.h"
#import "Photo.h"
#import "OriginPhoto.h"
#import "UIAlertView+Extension.h"
#import "Tag.h"
#import "CoredataCommon.h"
#import "FECoreDataController.h"
#import "AbstractInfo+Extension.h"

@interface FEUserEditVC ()<UIAlertViewDelegate>
@property (nonatomic, weak) FEUserInfoTVC* userInfoTVC;
@property (nonatomic, strong) User *user;
@end

@implementation FEUserEditVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userInfoTVC.view.layer.cornerRadius = 10.0;
    self.userInfoTVC.view.layer.borderWidth = 1.0;
    self.userInfoTVC.view.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.userInfoTVC.imageBtn.layer.cornerRadius = 10.0;
    self.userInfoTVC.imageBtn.layer.masksToBounds = YES;
    self.userInfoTVC.imageBtn.layer.borderWidth = 1.0;
    self.userInfoTVC.imageBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.user = [User getUser];
    self.userInfoTVC.nameTF.text = self.user.name;
    self.userInfoTVC.emailTF.text = self.user.email;
    if (self.user.photos.count > 0) {
        Photo *photo = [self.user firstPhoto];
        UIImage *image = [UIImage imageWithData:photo.originPhoto.imageData scale:[[UIScreen mainScreen] scale]];
        [self.userInfoTVC.imageBtn setImage:image forState:UIControlStateNormal];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"userInfo"]) {
        self.userInfoTVC = [segue destinationViewController];
    }
}
#define CONFIRM_ALERT 1000
#define FINISH_ALERT 1001
- (IBAction)closeButtonTapped:(UIButton *)sender {
    // some thing change
    if (self.userInfoTVC.textChanged || self.userInfoTVC.imageChanged) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Do you want to save?" delegate:self
                                                  cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = CONFIRM_ALERT;
        [alertView show];
    }
    else {
        [self close];
    }
}
- (void)close {
    [UIView transitionWithView:self.parentViewController.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.view removeFromSuperview];
                    } completion:^(BOOL finished) {
                        [self removeFromParentViewController];
                    }];
}- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == CONFIRM_ALERT) {
        // YES button
        if (buttonIndex == 1) {
            UIAlertView *savingAlertView = [UIAlertView indicatorAlertWithTitle:nil message:@"Saving..."];
            [savingAlertView show];
            // update User
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperationWithBlock:^{
                self.user.name = self.userInfoTVC.nameTF.text;
                self.user.email = self.userInfoTVC.emailTF.text;
                if (self.userInfoTVC.imageChanged) {
                    if (self.user.photos.count != 0) {
                        [self.user removePhotoAtIndex:0];
                    }
                    [self.user insertPhotoWithThumbnail:self.userInfoTVC.thumbnailImage andOriginImage:self.userInfoTVC.originImage];
                }
                [[FECoreDataController sharedInstance] saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
                    [savingAlertView dismissWithClickedButtonIndex:0 animated:YES];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Finish!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    alertView.delegate = self;
                    alertView.tag = FINISH_ALERT;
                    [alertView show];
                }];
            }];
        }
        // NO button
        else {
            [self close];
        }
    }
    else if (alertView.tag == FINISH_ALERT) {
        [self close];
    }
}
@end
