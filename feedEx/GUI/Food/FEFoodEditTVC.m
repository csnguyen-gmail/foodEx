//
//  FEEditFoodsTVC.m
//  feedEx
//
//  Created by csnguyen on 7/13/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFoodEditTVC.h"
#import "FECoreDataController.h"
#import "FEFoodEditListCell.h"
#import "GKImagePicker.h"
#import "Common.h"

@interface FEFoodEditTVC ()<FEFoodEditListCellDelegate, GKImagePickerDelegate>
@property (weak, nonatomic) FECoreDataController * coreData;
@property (strong, nonatomic) GKImagePicker *imagePicker;
@property (weak, nonatomic) FEFoodEditListCell *currentCell;
@end

@implementation FEFoodEditTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(addFood:) forControlEvents:UIControlEventValueChanged];
}
#pragma mark - event handler
-(void)addFood:(UIRefreshControl *)sender {
    Food *food =  [NSEntityDescription insertNewObjectForEntityForName:@"Food" inManagedObjectContext:self.coreData.managedObjectContext];
    food.placeOwner = self.place;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    [sender endRefreshing];
}
- (IBAction)editButtonTapped:(UIBarButtonItem *)sender {
    sender.title = self.tableView.editing ? @"Edit" : @"Done";
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

#pragma mark - setter gettr
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
}
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
    [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
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
    [self.currentCell addNewThumbnailImage:thumbnailImage andOriginImage:originImage];
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
    FEFoodEditListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FEFoodEditListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self updateCell:cell withFood:self.place.foods[indexPath.row] atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
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
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        // TODO
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    // TODO
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
@end
