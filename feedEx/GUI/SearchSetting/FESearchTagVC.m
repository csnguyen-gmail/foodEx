//
//  FESearchTagVC.m
//  feedEx
//
//  Created by csnguyen on 6/24/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchTagVC.h"

@interface FESearchTagVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *tags; // of Tag string

@property (nonatomic, strong) NSMutableArray *firstCharacters; // of first character of Tag
@property (nonatomic, strong) NSMutableArray *valuesOfSections; // of array value of section
@property (nonatomic, strong) NSMutableArray *checksOfSections; // of array check of section
@end

@implementation FESearchTagVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Tags";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self.delegate didSelectTags:[self.selectedTags sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
}

- (void)setTags:(NSArray *)tags {
    _tags = tags;
    self.firstCharacters = [[NSMutableArray alloc] init];
    for (NSString *tag in self.tags) {
        NSString *firstChar = [tag substringToIndex:1];
        if (![self.firstCharacters containsObject:firstChar]) {
            [self.firstCharacters addObject:firstChar];
        }
    }
    self.valuesOfSections = [[NSMutableArray alloc] init];
    for (NSString *firstCharacter in self.firstCharacters) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", firstCharacter];
        NSArray *valuesOfSection = [self.tags filteredArrayUsingPredicate:predicate];
        [self.valuesOfSections addObject:valuesOfSection];
    }
    
    self.checksOfSections = [[NSMutableArray alloc] init];
    for (NSArray *section in self.valuesOfSections) {
        NSMutableArray *checks = [[NSMutableArray alloc] init];
        for (NSString *value in section) {
            if ([self.selectedTags containsObject:value]) {
                [checks addObject:@(YES)];
            }
            else {
                [checks addObject:@(NO)];
            }
        }
        [self.checksOfSections addObject:checks];
    }
}
- (void)setSelectedTags:(NSMutableArray *)selectedTags {
    _selectedTags = selectedTags;
    self.tags = [self loadTagsFromCD];
}
- (NSArray*)loadTagsFromCD {
    // TODO
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"Aell%d", i]];
    }
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"Dell%d", i]];
    }
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"Fell%d", i]];
    }
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"Hell%d", i]];
    }
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"Nell%d", i]];
    }
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"Pell%d", i]];
    }
    for (int i = 0; i < 20; i++) {
        [array addObject:[NSString stringWithFormat:@"Xell%d", i]];
    }
    return array;
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.firstCharacters.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.firstCharacters[section];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.valuesOfSections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell) {
        cell.textLabel.text = self.valuesOfSections[indexPath.section][indexPath.row];
        BOOL isCheck = [self.checksOfSections[indexPath.section][indexPath.row] boolValue];
        cell.accessoryView = isCheck ? [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]] : nil;
    }
    for(UIView *view in [tableView subviews]) {
        if([view respondsToSelector:@selector(setIndexColor:)]) {
            [view performSelector:@selector(setIndexColor:) withObject:[UIColor whiteColor]];
        }
    }
    return cell;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.firstCharacters;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL newCheck = ![self.checksOfSections[indexPath.section][indexPath.row] boolValue];
    self.checksOfSections[indexPath.section][indexPath.row] = @(newCheck);
    cell.accessoryView = newCheck ? [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]] : nil;
    if (newCheck) {
        [self.selectedTags addObject:cell.textLabel.text];
    }
    else {
        [self.selectedTags removeObject:cell.textLabel.text];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
