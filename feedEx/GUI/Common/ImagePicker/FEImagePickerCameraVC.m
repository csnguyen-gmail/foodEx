//
//  FEImagePickerCameraVC.m
//  NewImagePicker
//
//  Created by csnguyen on 11/6/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEImagePickerCameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Extension.h"
#import "FEImagePickerGridView.h"
#import "FEImagePickerFocusView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FEImagePickerCameraVC ()<FEImagePickerGridViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) IBOutlet FEImagePickerGridView *gridView;
@property (strong, nonatomic) UIView *focusView;
@property (nonatomic) BOOL isUsingBackCamera;
@property (nonatomic) NSInteger flashType;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicationView;
// The lifetimes of objects you get back from a library instance are tied to the lifetime of the library instance.
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@end

@implementation FEImagePickerCameraVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gridView.numberOfLine = 3;
    self.gridView.hiddenGrid = NO;
    self.gridView.delegate = self;
    self.isUsingBackCamera = YES;
    self.flashType = AVCaptureFlashModeAuto;
    self.photoImageView.layer.cornerRadius = 2.0;
    self.photoImageView.layer.masksToBounds = YES;
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        [self loadFirstImageFromPhoto];
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Note: can not setup on background thread, it may occur black screen
//    [self.indicationView startAnimating];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperationWithBlock:^{
        [self setupCameraSession];
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.session startRunning];
//            [self.indicationView stopAnimating];
//        }];
//    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}
- (void)setupCameraSession
{
    // Session
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // Capture device
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    // Device input
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
	if ( [self.session canAddInput:deviceInput] ) {
		[self.session addInput:deviceInput];
    }
    
    // Preview
	AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    previewLayer.frame = self.previewView.bounds;
    [self.previewView.layer addSublayer:previewLayer];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // Output
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.stillImageOutput setOutputSettings:@{AVVideoCodecJPEG:AVVideoCodecJPEG}];
    [self.session addOutput:self.stillImageOutput];
}
- (void)shootImage {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    // set image orientation follow gravity
    if (videoConnection.isVideoOrientationSupported) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if ((orientation == UIDeviceOrientationFaceUp) || (orientation == UIDeviceOrientationFaceDown)) {
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        else {
            [videoConnection setVideoOrientation:(AVCaptureVideoOrientation)orientation];
        }
    }
    // keep image as it be in case use front camera
    if (videoConnection.isVideoMirroringSupported) {
        [videoConnection setVideoMirrored:!self.isUsingBackCamera];
    }

    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        [self.session stopRunning];
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        image = [UIImage imageWithImage:image resizeAndCropAutoFitCenterForSize:CGSizeMake(320.0, 320.0)];
        [self.delegate imagePickerCamera:self didFinishWithImage:image];
     }];

}
- (void)swapCameras {
    AVCaptureDevicePosition desiredPosition;
    if (self.isUsingBackCamera) {
        desiredPosition = AVCaptureDevicePositionFront;
    } else {
        desiredPosition = AVCaptureDevicePositionBack;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType: AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in [[self session] inputs]) {
                [self.session removeInput:oldInput];
            }
            [self.session addInput:input];
            [self.session commitConfiguration];
            break;
        }
    }
    self.isUsingBackCamera = !self.isUsingBackCamera;
}
- (void)setFlashType:(NSInteger)flashType {
    _flashType = flashType;
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([inputDevice hasFlash] && [inputDevice hasTorch]) {
        [inputDevice lockForConfiguration:nil];
        inputDevice.flashMode = flashType;
        [inputDevice unlockForConfiguration];
    }
}
- (void) focus:(CGPoint) point;
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isFocusPointOfInterestSupported] &&
       [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGRect screenRect = self.gridView.frame;
        double screenWidth = screenRect.size.width;
        double screenHeight = screenRect.size.height;
        double focus_x = point.x/screenWidth;
        double focus_y = point.y/screenHeight;
        if([device lockForConfiguration:nil]) {
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];
        }
    }
}
- (void) loadFirstImageFromPhoto {
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                NSLog(@"The user has declined access to it.");
                break;
            default:
                NSLog(@"Reason unknown.");
                break;
        }
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    *stop = YES;
                    CGImageRef thumbnailImageRef = [result thumbnail];
                    CGImageRetain(thumbnailImageRef);
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        self.photoImageView.image = [UIImage imageWithCGImage:thumbnailImageRef];;
                        CGImageRelease(thumbnailImageRef);
                    }];
                }
            };
            
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [self.assetGroup setAssetsFilter:onlyPhotosFilter];
            [self.assetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetsEnumerationBlock];
        }
        else {
            self.assetGroup = group;
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}
#pragma mark - Rotation controller
-(BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientation{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - Event handler
- (IBAction)switchPhotoTapped:(UIButton *)sender {
    [self.delegate imagePickerCameraSwithToPhoto:self];
}

- (IBAction)shootTapped:(UIButton *)sender {
    [self shootImage];
}
- (IBAction)cancelTapped:(UIButton *)sender {
    [self.delegate imagePickerCamera:self didFinishWithImage:nil];
}
- (IBAction)gridToggleTapped:(UIButton *)sender {
    self.gridView.hiddenGrid = !self.gridView.hiddenGrid;
}
- (IBAction)swapCameraTapped:(UIButton *)sender {
    [self swapCameras];
}
- (IBAction)flashTypeTapped:(UIButton *)sender {
    if (self.flashType == AVCaptureFlashModeAuto) {
        [sender setImage:[UIImage imageNamed:@"camera-glyph-flash-off"] forState:UIControlStateNormal];
        self.flashType = AVCaptureFlashModeOff;
    }
    else if (self.flashType == AVCaptureFlashModeOff) {
        [sender setImage:[UIImage imageNamed:@"camera-glyph-flash-on"] forState:UIControlStateNormal];
        self.flashType = AVCaptureFlashModeOn;
    }
    else {
        [sender setImage:[UIImage imageNamed:@"camera-glyph-flash-auto"] forState:UIControlStateNormal];
        self.flashType = AVCaptureFlashModeAuto;
    }
}
- (void)tapAtPoint:(CGPoint)point {
    [self focus:point];
    if (self.focusView) {
        [self.focusView removeFromSuperview];
    }
    self.focusView = [[FEImagePickerFocusView alloc] initWithFrame:CGRectMake(point.x-40, point.y-40, 80, 80)];
    self.focusView.backgroundColor = [UIColor clearColor];
    [self.gridView addSubview:self.focusView];
    [self.focusView setNeedsDisplay];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0];
    [self.focusView setAlpha:0.0];
    [UIView commitAnimations];}
@end
