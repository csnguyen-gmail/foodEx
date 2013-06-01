//
//  FETestViewController.m
//  feedEx
//
//  Created by csnguyen on 5/17/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FETestViewController.h"
#import "FENextInputAccessoryView.h"
@interface FETestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *nextTextField;
@end

@implementation FETestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"More"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self action:@selector(hello:)];
    moreButton.tintColor = [UIColor redColor];
    self.textField.inputAccessoryView = [[FENextInputAccessoryView alloc] initWithNextTextField:self.nextTextField additionalButtons:@[moreButton]];
}
-(void)hello:(id)sender {
    NSLog(@"hello");
}

- (void)viewDidUnload {
    [self setDynamicScrollView:nil];
    [self setCapturedImageView:nil];
    [self setTextField:nil];
    [self setNextTextField:nil];
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
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
                                                              deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]]];
        [wiggleViews addObject:wiggleView];
    }
    self.dynamicScrollView.wiggleViews = wiggleViews;
}
- (void)viewDidDisappear:(BOOL)animated {
    self.dynamicScrollView.editMode = NO;
}
- (IBAction)addTapped:(id)sender {
    FEWiggleView *wiggleView = [[FEWiggleView alloc] initWithMainView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"a_t"]]
                                                           deleteView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]]];
    [self.dynamicScrollView addView:wiggleView atIndex:0];
}
- (IBAction)endEdit:(id)sender {
    self.dynamicScrollView.editMode = !self.dynamicScrollView.editMode;
}
- (IBAction)captureTapped:(id)sender {
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
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.capturedImageView.image = image;
}

@end
