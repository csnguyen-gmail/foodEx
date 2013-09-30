//
//  FEFriendsVC.m
//  feedEx
//
//  Created by csnguyen on 9/30/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FEFriendsVC.h"
#import "User+Extension.h"
#import "Photo.h"
#import "ThumbnailPhoto.h"
#import "Common.h"
#import "FEUserListCell.h"
#import "CoredataCommon.h"
#import <QuartzCore/QuartzCore.h>

@interface FEFriendsVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *firstCharacters; // of first character of Tag
@property (nonatomic, strong) NSMutableArray *valuesOfSections; // of array value of section
\
@end

@implementation FEFriendsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    self.tableView.layer.cornerRadius = 10;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coredateChanged:)
                                                 name:CORE_DATA_UPDATED object:nil];
    [self refetchData];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CORE_DATA_UPDATED object:nil];
}

- (void)refetchData {
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    self.friends = [User fetchUsersByEmail:nil type:USER_FRIEND_TAG sorts:@[sort]];
    self.firstCharacters = [[NSMutableArray alloc] init];
    for (User *user in self.friends) {
        NSString *firstChar = [user.name substringToIndex:1];
        if (![self.firstCharacters containsObject:firstChar]) {
            [self.firstCharacters addObject:firstChar];
        }
    }
    self.valuesOfSections = [[NSMutableArray alloc] init];
    for (NSString *firstCharacter in self.firstCharacters) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", firstCharacter];
        NSMutableArray *valuesOfSection = [[self.friends filteredArrayUsingPredicate:predicate] mutableCopy];
        [self.valuesOfSections addObject:valuesOfSection];
    }
    [self.tableView reloadData];
}

#pragma mark - handler DataModel changed
- (void)coredateChanged:(NSNotification *)info {
    [self refetchData];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.firstCharacters.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.firstCharacters[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.valuesOfSections[section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.firstCharacters;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // change color of letters of sectionIndexTitlesForTableView -> BAD
    for(UIView *view in [tableView subviews]) {
        if([view respondsToSelector:@selector(setIndexColor:)]) {
            [view performSelector:@selector(setIndexColor:) withObject:[UIColor whiteColor]];
        }
    }
    
    static NSString *CellIdentifier = @"UserListCell";
    FEUserListCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:(NSIndexPath *)indexPath];
    return cell;
}
- (void)updateCell:(FEUserListCell*)cell atIndexPath:(NSIndexPath *)indexPath{
    User *user = self.valuesOfSections[indexPath.section][indexPath.row];
    Photo *photo;
    if (user.photos.count != 0) {
        photo = user.photos[0];
    }
    cell.userImageView.image = photo.thumbnailPhoto.image;
    cell.userNameLbl.text = user.name;
    cell.userEmailLbl.text = user.email;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

@end
