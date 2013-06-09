//
//  FEEditPlaceInfoTVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoTVC.h"
#import "CPTextViewPlaceholder.h"
#import <QuartzCore/QuartzCore.h>

@interface FEEditPlaceInfoTVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *stopEditButton;
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *photoScrollView;
@property (strong, nonatomic) NSArray *tags; // array of NSString
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
    // set up imput accesory view
    [self setupInputAccesoryView];
    
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
#pragma mark - getter setter
- (NSArray *)tags {
    if (!_tags) {
        // TODO - load tags from db
        _tags = @[@"abc", @"def", @"ghi", @"jkl", @"mno", @"pqr", @"stu", @"vxyz"];
    }
    return  _tags;
}
#pragma mark - Utility
#define BAR_BUTTON_NAME     1000
#define BAR_BUTTON_ADDRESS  1001
#define BAR_BUTTON_TAG      1002
#define BAR_BUTTON_NOTE     1003
- (void)setupInputAccesoryView {
    UIBarButtonItem *barButton;
    // name text field
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                target:self action:@selector(buttonInAccessryTapped:)];
    barButton.tag = BAR_BUTTON_NAME;
    barButton.tintColor = [UIColor blackColor];
    self.nameTextField.inputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]];
    // address text field
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                target:self action:@selector(buttonInAccessryTapped:)];
    barButton.tag = BAR_BUTTON_ADDRESS;
    barButton.tintColor = [UIColor blackColor];
    self.addressTextField.inputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]];
    // tag text field
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone
                                                target:self action:@selector(buttonInAccessryTapped:)];
    barButton.tag = BAR_BUTTON_TAG;
    barButton.tintColor = [UIColor blackColor];
    FECustomInputAccessoryView *customInputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]
                                                                                             andSuggestionWord:self.tags];
    customInputAccessoryView.delegate = self;
    self.tagTextField.inputAccessoryView = customInputAccessoryView;
    // note text view
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                                target:self action:@selector(buttonInAccessryTapped:)];
    barButton.tag = BAR_BUTTON_NOTE;
    self.noteTextView.inputAccessoryView = [[FECustomInputAccessoryView alloc] initWithButtons:@[barButton]];
}
- (void)buttonInAccessryTapped:(UIBarButtonItem*)sender {
    if (sender.tag == BAR_BUTTON_NAME) {
        [self.addressTextField becomeFirstResponder];
    }
    else if (sender.tag == BAR_BUTTON_ADDRESS) {
        [self.tagTextField becomeFirstResponder];
    }
    else if (sender.tag == BAR_BUTTON_TAG) {
        [self.noteTextView becomeFirstResponder];
    }
    else if (sender.tag == BAR_BUTTON_NOTE) {
        [self.noteTextView resignFirstResponder];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (IBAction)tagDidChange:(UITextField *)sender {
    if ([sender.inputAccessoryView isKindOfClass:[FECustomInputAccessoryView class]]) {
        FECustomInputAccessoryView *inputAccessoryView = (FECustomInputAccessoryView*)sender.inputAccessoryView;
        inputAccessoryView.filterWord = sender.text;
        // TODO - get text after comma
    }
}
- (void)suggestionWordTapped:(NSString *)word {
    self.tagTextField.text = word;
    // TODO - set text after comma
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
    // TODO - manege image array
}

@end
