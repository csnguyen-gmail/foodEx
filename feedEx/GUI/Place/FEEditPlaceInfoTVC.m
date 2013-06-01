//
//  FEEditPlaceInfoTVC.m
//  feedEx
//
//  Created by csnguyen on 5/12/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEEditPlaceInfoTVC.h"
#import "FENextInputAccessoryView.h"
#import "UIImage+Extension.h"
#import <QuartzCore/QuartzCore.h>

@interface FEEditPlaceInfoTVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *stopEditButton;
@property (weak, nonatomic) IBOutlet FEDynamicScrollView *wigglePhotoScrollView;
@end

@implementation FEEditPlaceInfoTVC
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setNoteTextView:nil];
    [self setNameTextField:nil];
    [self setAddressTextField:nil];
    [self setTagTextField:nil];
    [self setWigglePhotoScrollView:nil];
    [self setAddPhotoButton:nil];
    [self setStopEditButton:nil];
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated {
    // make rounded rectangle table
    self.tableView.layer.cornerRadius = 10;
    self.tableView.bounces = NO;
    self.noteTextView.layer.cornerRadius = 10;
    self.noteTextView.layer.borderWidth = 1;
    self.noteTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    // photo scroll view
    NSMutableArray *images = [NSMutableArray arrayWithArray:@[[UIImage imageNamed:@"a_t"],
                              [UIImage imageNamed:@"b_t"],
                              [UIImage imageNamed:@"c_t"],
                              [UIImage imageNamed:@"d_t"],
                              [UIImage imageNamed:@"e_t"],
                              [UIImage imageNamed:@"a_t"],
                              [UIImage imageNamed:@"b_t"],
                              [UIImage imageNamed:@"c_t"],
                              [UIImage imageNamed:@"d_t"],
                              [UIImage imageNamed:@"e_t"]]];
    NSMutableArray *wiggleViews = [[NSMutableArray alloc] init];
    for (UIImage *image in images) {
        // set up wiggle image view
        FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:image]
                                                               deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remove"]]];
        [wiggleViews addObject:wiggleView];
    }
    self.wigglePhotoScrollView.wiggleViews = wiggleViews;
    self.wigglePhotoScrollView.dynamicScrollViewDelegate = self;
    self.addPhotoButton.hidden = NO;
    self.stopEditButton.hidden = YES;
    // name text field
    self.nameTextField.inputAccessoryView = [[FENextInputAccessoryView alloc] initWithNextTextField:self.addressTextField
                                                                                  additionalButtons:nil];
    // address text field
    UIBarButtonItem *addressMoreButton = [[UIBarButtonItem alloc] initWithTitle:@"More"
                                                                          style:UIBarButtonItemStyleDone
                                                                         target:self
                                                                         action:@selector(moreAddressTapped:)];
    addressMoreButton.tintColor = [UIColor redColor];
    self.addressTextField.inputAccessoryView = [[FENextInputAccessoryView alloc] initWithNextTextField:self.tagTextField
                                                                                     additionalButtons:@[addressMoreButton]];
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
- (void)viewDidDisappear:(BOOL)animated {
    self.wigglePhotoScrollView.editMode = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Utility
- (NSUInteger)getHeightOfTable {
    CGRect rect = [self.tableView rectForSection:0];
    return rect.size.height;
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
    self.wigglePhotoScrollView.editMode = NO;
}
- (IBAction)addPhotoTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"showImagePickerSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIImagePickerController *controller = [segue destinationViewController];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.allowsEditing = YES;
    controller.delegate = self;
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *originImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *thumbnailImage = [UIImage imageWithImage:originImage scaledToSize:CGSizeMake(64.0, 64.0)];
    
    FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:thumbnailImage]
                                                           deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]]];
    [self.wigglePhotoScrollView addView:wiggleView atIndex:0];
    // TODO
}

@end
