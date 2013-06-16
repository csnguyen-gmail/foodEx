//
//  FEEditPlaceInfoTVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoTVC.h"
#import "FECustomInputAccessoryView.h"
#import "FEAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface FEEditPlaceInfoTVC ()
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *stopEditButton;
@property (strong, nonatomic) GKImagePicker *imagePicker;
@end

@implementation FEEditPlaceInfoTVC
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionWhenViewDisappear) name:NTF_APP_WILL_RESIGN_ACTIVE object:nil];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_APP_WILL_RESIGN_ACTIVE object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // common setup
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.noteTextView.placeholder = @"Add note here";
    self.tagTextView.placeholder = @"Add tag here, separated by comma";
    // make rounded rectangle table
    self.tableView.layer.cornerRadius = 10;
    self.tableView.bounces = NO;
    self.noteTextView.layer.cornerRadius = 10;
    self.noteTextView.layer.borderWidth = 1;
    self.noteTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.tagTextView.layer.cornerRadius = 10;
    self.tagTextView.layer.borderWidth = 1;
    self.tagTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.deleteButton.layer.cornerRadius = 10;
    self.deleteButton.layer.masksToBounds = YES;
    // photo scroll view
    NSMutableArray *wiggleViews = [[NSMutableArray alloc] init];
    self.photoScrollView.wiggleViews = wiggleViews;
    self.photoScrollView.dynamicScrollViewDelegate = self;
    self.addPhotoButton.hidden = NO;
    self.stopEditButton.hidden = YES;
    // set up imput accesory view
    [self setupInputAccesoryView];
    
}

- (void)viewDidUnload {
    [self setNoteTextView:nil];
    [self setNameTextField:nil];
    [self setAddressTextField:nil];
    [self setTagTextView:nil];
    [self setPhotoScrollView:nil];
    [self setAddPhotoButton:nil];
    [self setStopEditButton:nil];
    [self setDeleteButton:nil];
    [self setRatingView:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self actionWhenViewDisappear];
}
#pragma mark - getter setter
- (NSArray *)tags {
    if (!_tags) {
        // TODO - load tags from db
        _tags = @[@"abc", @"def", @"ghi", @"jkl", @"mno", @"pqr", @"stu", @"vxyz"];
    }
    return  _tags;
}
#pragma mark - Utility
- (void)actionWhenViewDisappear {
    [self exitEditMode];
}

#define BAR_BUTTON_NAME     1000
#define BAR_BUTTON_ADDRESS  1001
#define BAR_BUTTON_NOTE     1003
- (void)setupInputAccesoryView {
    UIBarButtonItem *barButton;
    // name text field
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                target:self action:@selector(buttonInAccessoryTapped:)];
    barButton.tag = BAR_BUTTON_NAME;
    barButton.tintColor = [UIColor blackColor];
    self.nameTextField.inputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]];
    // address text field
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                target:self action:@selector(buttonInAccessoryTapped:)];
    barButton.tag = BAR_BUTTON_ADDRESS;
    barButton.tintColor = [UIColor blackColor];
    self.addressTextField.inputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]];
    // tag text field
    self.tagTextView.nextTextField = self.noteTextView;
    self.tagTextView.tags = self.tags;
    // note text view
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                                target:self action:@selector(buttonInAccessoryTapped:)];
    barButton.tag = BAR_BUTTON_NOTE;
    self.noteTextView.inputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]];
}
- (void)buttonInAccessoryTapped:(UIBarButtonItem*)sender {
    if (sender.tag == BAR_BUTTON_NAME) {
        [self.addressTextField becomeFirstResponder];
    }
    else if (sender.tag == BAR_BUTTON_ADDRESS) {
        [self.tagTextView becomeFirstResponder];
    }
    else if (sender.tag == BAR_BUTTON_NOTE) {
        [self.noteTextView resignFirstResponder];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
- (void)exitEditMode {
    self.addPhotoButton.hidden = NO;
    self.stopEditButton.hidden = YES;
    self.photoScrollView.editMode = NO;
}
- (IBAction)stopEditButtonTapped:(UIButton *)sender {
    [self exitEditMode];
}
- (IBAction)addPhotoTapped:(UIButton *)sender {
    [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
}
- (void)setupPhotoScrollViewWithArrayOfThumbnailImages:(NSArray *)thumbnailImages {
    for (UIImage *thumbnailImage in thumbnailImages) {
        FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                               deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
        [self.photoScrollView addView:wiggleView atIndex:self.photoScrollView.wiggleViews.count];
    }
}
- (void)removeImageAtIndex:(NSUInteger)index {
    [self.editPlaceTVCDelegate removeImageAtIndex:index];
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
    [self.editPlaceTVCDelegate addNewThumbnailImage:thumbnailImage andOriginImage:originImage];
}

@end
