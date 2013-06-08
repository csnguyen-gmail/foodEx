//
//  FEEditPlaceInfoTVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoTVC.h"
#import "FENextInputAccessoryView.h"
#import "CPTextViewPlaceholder.h"
#import <QuartzCore/QuartzCore.h>

@interface FEEditPlaceInfoTVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *stopEditButton;
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *photoScrollView;
@property (strong, nonatomic) GKImagePicker *imagePicker;
@end

@implementation FEEditPlaceInfoTVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    // common setup
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.noteTextView.placeholder = @"Add note here";
    // make rounded rectangle table
    self.tableView.layer.cornerRadius = 10;
    self.tableView.bounces = NO;
    self.noteTextView.layer.cornerRadius = 10;
    self.noteTextView.layer.borderWidth = 1;
    self.noteTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    // photo scroll view
    NSMutableArray *wiggleViews = [[NSMutableArray alloc] init];
    self.photoScrollView.wiggleViews = wiggleViews;
    self.photoScrollView.dynamicScrollViewDelegate = self;
    self.addPhotoButton.hidden = NO;
    self.stopEditButton.hidden = YES;
    // name text field
    self.nameTextField.inputAccessoryView = [[FENextInputAccessoryView alloc] initWithNextTextField:self.addressTextField
                                                                                  additionalButtons:nil];
    // address text field
    self.addressTextField.inputAccessoryView = [[FENextInputAccessoryView alloc] initWithNextTextField:self.tagTextField
                                                                                  additionalButtons:nil];
    // tag text field
    self.tagTextField.inputAccessoryView = [[FENextInputAccessoryView alloc] initWithNextTextField:self.noteTextView
                                                                                 additionalButtons:nil];
    // note text view
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(commentDoneTapped:)];
    self.noteTextView.inputAccessoryView = [[FENextInputAccessoryView alloc] initWithNextTextField:nil
                                                                                 additionalButtons:@[doneButton]];
}

- (void)viewDidUnload {
    [self setNoteTextView:nil];
    [self setNameTextField:nil];
    [self setAddressTextField:nil];
    [self setTagTextField:nil];
    [self setPhotoScrollView:nil];
    [self setAddPhotoButton:nil];
    [self setStopEditButton:nil];
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated {
}
- (void)viewDidDisappear:(BOOL)animated {
    self.photoScrollView.editMode = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Utility
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
#pragma mark - Address
- (void)moreAddressTapped:(id)sender {
    // TODO
}
#pragma mark - Comment
- (void)commentDoneTapped:(id)sender {
    [self.noteTextView resignFirstResponder];
}
#pragma mark - Photos
- (void)enterDraggingMode {
    self.tableView.scrollEnabled = NO;
    if ([self.view.superview respondsToSelector:@selector(setScrollEnabled:)]) {
        [(id)self.view.superview setScrollEnabled:NO];
    }
}
- (void)exitDraggingMode {
    self.tableView.scrollEnabled = YES;
    if ([self.view.superview respondsToSelector:@selector(setScrollEnabled:)]) {
        [(id)self.view.superview setScrollEnabled:YES];
    }
}
- (void)enterEditMode {
    self.addPhotoButton.hidden = YES;
    self.stopEditButton.hidden = NO;
}
- (IBAction)stopEditButtonTapped:(UIButton *)sender {
    self.addPhotoButton.hidden = NO;
    self.stopEditButton.hidden = YES;
    self.photoScrollView.editMode = NO;
}
- (IBAction)addPhotoTapped:(UIButton *)sender {
    [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
}
# pragma mark - GKImagePicker Delegate Methods
- (GKImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[GKImagePicker alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}
- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    [self.imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    UIImage *originImage = image;
    UIImage *thumbnailImage = [UIImage imageWithImage:originImage scaledToSize:CGSizeMake(64.0, 64.0)];
    FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                           deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
    [self.photoScrollView addView:wiggleView atIndex:0];
    // TODO
}

@end
