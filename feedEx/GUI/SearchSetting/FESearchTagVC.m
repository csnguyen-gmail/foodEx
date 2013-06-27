//
//  FESearchTagVC.m
//  feedEx
//
//  Created by csnguyen on 6/24/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchTagVC.h"
#import "FECoreDataController.h"
#import "Tag+Extension.h"
#import "CoredataCommon.h"
#import "FESearchTagCell.h"

@interface FESearchTagVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *tags; // of Tag string
@property (nonatomic, strong) NSMutableArray *selectedTags; // of NSString
@property (nonatomic, strong) NSMutableArray *firstCharacters; // of first character of Tag
@property (nonatomic, strong) NSMutableArray *valuesOfSections; // of array value of section
@property (nonatomic, strong) NSMutableArray *checksOfSections; // of array check of section
@property (weak, nonatomic) FECoreDataController * coreData;
@end

@implementation FESearchTagVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Tags";
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor grayColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [self.delegate didSelectTags:[self.selectedTags sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
}
- (void)loadTagWithTagType:(NSNumber *)tagType andSelectedTags:(NSArray *)selectTags {
    self.selectedTags = [selectTags mutableCopy];
    self.tags = [Tag fetchTagsByType:tagType
                             withMOM:self.coreData.managedObjectModel
                              andMOC:self.coreData.managedObjectContext];
}
- (void)setTags:(NSArray *)tags {
    _tags = tags;
    self.firstCharacters = [[NSMutableArray alloc] init];
    for (Tag *tag in self.tags) {
        NSString *firstChar = [tag.label substringToIndex:1];
        if (![self.firstCharacters containsObject:firstChar]) {
            [self.firstCharacters addObject:firstChar];
        }
    }
    self.valuesOfSections = [[NSMutableArray alloc] init];
    for (NSString *firstCharacter in self.firstCharacters) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label beginswith[c] %@", firstCharacter];
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
- (FECoreDataController *)coreData {
    if (!_coreData) {
        _coreData = [FECoreDataController sharedInstance];
    }
    return _coreData;
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
    FESearchTagCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell) {
        Tag *tag = self.valuesOfSections[indexPath.section][indexPath.row];
        NSString *tagTypeStr = (([tag.type isEqual: CD_TAG_PLACE]) ? @"place" : @"food");
        cell.tagName.text = tag.label;
        cell.tagDetail.text = [NSString stringWithFormat:@"%d %@", tag.owner.count, tagTypeStr];
        BOOL isCheck = [self.checksOfSections[indexPath.section][indexPath.row] boolValue];
        cell.checkMarkView.image = isCheck ? [UIImage imageNamed:@"checkmark"] : nil;
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tag *tag = self.valuesOfSections[indexPath.section][indexPath.row];
    if (tag.owner.count == 0) {
        return;
    }
    FESearchTagCell *cell = (FESearchTagCell*)[tableView cellForRowAtIndexPath:indexPath];
    BOOL newCheck = ![self.checksOfSections[indexPath.section][indexPath.row] boolValue];
    self.checksOfSections[indexPath.section][indexPath.row] = @(newCheck);
    cell.checkMarkView.image = newCheck ? [UIImage imageNamed:@"checkmark"] : nil;
}

@end
