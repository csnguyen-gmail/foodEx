//
//  FEPlaceEditTVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEPlaceEditTVC.h"
#import "FECustomInputAccessoryView.h"
#import "FEAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"

@interface FEPlaceEditTVC ()
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (strong, nonatomic) GKImagePicker *imagePicker;
@end

@implementation FEPlaceEditTVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    // common setup
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.noteTextView.placeholder = @"Add note here";
    self.tagTextView.placeholder = @"Add tag here, separated by [,]";
    self.tagTextView.delegate = self;
    // make rounded rectangle table
    self.tableView.layer.cornerRadius = 10;
    self.noteTextView.layer.cornerRadius = 10;
    self.noteTextView.layer.borderWidth = 1;
    self.noteTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.tagTextView.layer.cornerRadius = 10;
    self.tagTextView.layer.borderWidth = 1;
    self.tagTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.deleteButton.layer.cornerRadius = 10;
    self.deleteButton.layer.masksToBounds = YES;
    // photo scroll view
    self.photoScrollView.dynamicScrollViewDelegate = self;
    // rating view
    [self.ratingView setupBigStarEditable:YES];
    // set up imput accesory view
    [self setupInputAccesoryView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionWhenViewDisappear) name:NTF_APP_WILL_RESIGN_ACTIVE object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NTF_APP_WILL_RESIGN_ACTIVE object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self actionWhenViewDisappear];
}
#pragma mark - getter setter
- (void)setTags:(NSArray *)tags {
    _tags = tags;
    self.tagTextView.tags = tags;
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
    self.photoButton.selected = YES;
}
- (void)exitEditMode {
    self.photoButton.selected = NO;
    self.photoScrollView.editMode = NO;
}
- (IBAction)photoButtonTapped:(UIButton *)sender {
    if (self.photoButton.selected) {
        [self exitEditMode];
    }
    else {
        [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
    }
}
- (void)setupPhotoScrollViewWithArrayOfThumbnailImages:(NSArray *)thumbnailImages {
    NSMutableArray *wiggles = [NSMutableArray array];
    for (UIImage *thumbnailImage in thumbnailImages) {
        FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                               deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
        [wiggles addObject:wiggleView];
    }
    [self.photoScrollView setupWithWiggleArray:wiggles withAnimation:NO];
}
- (void)removeImageAtIndex:(NSUInteger)index {
    [self.editPlaceTVCDelegate removeImageAtIndex:index];
}
- (void)viewMovedFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    [self.editPlaceTVCDelegate imageMovedFromIndex:fromIndex toIndex:toIndex];
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
    UIImage *originImage = [UIImage imageWithImage:image
                                      scaledToSize:NORMAL_SIZE];
    UIImage *thumbnailImage = [UIImage imageWithImage:image
                                         scaledToSize:THUMBNAIL_SIZE];
    FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                           deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
    [self.photoScrollView addView:wiggleView atIndex:0 withAnimation:YES];
    [self.editPlaceTVCDelegate addNewThumbnailImage:thumbnailImage andOriginImage:originImage];
}
# pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    FETagTextView *tagTextView = (FETagTextView*)textView;
    [tagTextView didBeginEditing];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    FETagTextView *tagTextView = (FETagTextView*)textView;
    [tagTextView didChangeSelection];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    FETagTextView *tagTextView = (FETagTextView*)textView;
    [tagTextView didEndEditing];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    FETagTextView *tagTextView = (FETagTextView*)textView;
    return [tagTextView shouldChangeTextInRange:range replacementText:text];
}
@end
