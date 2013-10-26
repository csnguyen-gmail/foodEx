//
//  FEFoodEditVC.m
//  feedEx
//
//  Created by csnguyen on 7/20/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodEditVC.h"
#import "FEFoodEditListCell.h"
#import "FEImagePicker.h"
#import "Common.h"
#import "Place+Extension.h"
#import <QuartzCore/QuartzCore.h>


@interface FEFoodEditVC ()<FEFoodEditListCellDelegate, FEImagePickerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) FEImagePicker *imagePicker;
@property (weak, nonatomic) FEFoodEditListCell *currentCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UITableViewCell *activeCellView;
@property (nonatomic) CGFloat keyboardDelta;
@property (nonatomic) CGFloat maxTableHeight;
@end

@implementation FEFoodEditVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editFood:)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFood:)];
    self.navigationItem.rightBarButtonItems = @[addButton, editButton];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    if (self.maxTableHeight == 0) {
        self.maxTableHeight = self.tableView.frame.size.height;
    }
    [self adjustTableHeight];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)adjustTableHeight {
    float tableHeight = [self.tableView rectForSection:0].size.height - 1;
    if (tableHeight > self.maxTableHeight) {
        tableHeight = self.maxTableHeight;
    }
    else if (tableHeight < 0) {
        tableHeight = 0;
    }
    CGRect frame = self.tableView.frame;
    if (frame.size.height != tableHeight) {
        frame.size.height = tableHeight;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = frame;
        }];
    }
}

#pragma mark - event handler
- (void)addFood:(UIBarButtonItem *)sender {
    [self.place insertFoodsAtIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [self adjustTableHeight];
}
- (void)editFood:(UIBarButtonItem *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    UIBarButtonItem *addButton = self.navigationItem.rightBarButtonItems[0];
    if (self.tableView.editing) {
        sender.title = @"Done";
        sender.tintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        addButton.enabled = NO;
    } else {
        sender.title = @"Edit";
        sender.tintColor = [UIColor darkGrayColor];
        addButton.enabled = YES;
    }
}
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint origin = [self.view convertPoint:self.activeCellView.frame.origin fromView:self.tableView] ;
    self.keyboardDelta = (origin.y + self.activeCellView.frame.size.height) - (self.view.frame.size.height - kbSize.height);
    if (self.keyboardDelta > 0) {
        CGRect frame = self.tableView.frame;
        frame.origin.y -= self.keyboardDelta;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = frame;
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.keyboardDelta > 0) {
        CGRect frame = self.tableView.frame;
        frame.origin.y += self.keyboardDelta;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = frame;
        }];
    }
}
#pragma mark - setter gettr
- (void)setPlace:(Place *)place {
    _place = place;
    [self.tableView reloadData];
}
#pragma mark - common
- (void)updateCell:(FEFoodEditListCell*)cell withFood:(Food*)food atIndexPath:(NSIndexPath*)indexPath {
    cell.delegate = self;
    cell.food = food;
}
#pragma mark - FEFoodEditListCellDelegate
- (void)enterDraggingMode {
    self.tableView.scrollEnabled = NO;
}
- (void)exitDraggingMode {
    self.tableView.scrollEnabled = YES;
}
- (void)selectImageAtCell:(FEFoodEditListCell *)cell {
    self.currentCell = cell;
    [self.imagePicker startPickerFrom:self];
}
- (void)cellDidBeginEditing:(UITableViewCell *)cell {
    self.activeCellView = cell;
}
- (void)cellDidEndEditing:(UITableViewCell *)cell {
    self.activeCellView = nil;
}
# pragma mark - FEImagePickerDelegate
- (FEImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[FEImagePicker alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}
- (void)imagePicker:(FEImagePicker *)imagePicker pickedImage:(UIImage *)image{
    UIImage *originImage = [UIImage imageWithImage:image
                                      scaledToSize:NORMAL_SIZE];
    UIImage *thumbnailImage = [UIImage imageWithImage:image
                                         scaledToSize:THUMBNAIL_SIZE];
    [self.currentCell addNewThumbnailImage:thumbnailImage andOriginImage:originImage];
    // release image picker
    self.imagePicker = nil;
}
- (void)imagePickerCancel {
    // release image picker
    self.imagePicker = nil;

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.place.foods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FoodListCell";
    FEFoodEditListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell withFood:self.place.foods[indexPath.row] atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 112;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.editing;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.place removeFoodAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self adjustTableHeight];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.place moveFoodFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
@end

