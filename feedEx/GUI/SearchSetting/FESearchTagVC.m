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
#import "Common.h"

@interface FESearchTagVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *firstCharacters; // of first character of Tag
@property (nonatomic, strong) NSMutableArray *valuesOfSections; // of array value of section
@property (nonatomic, strong) NSMutableArray *checksOfSections; // of array check of section
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
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
        if ([self.delegate respondsToSelector:@selector(didSelectTags:)]) {
            [self.delegate didSelectTags:[self getSelectedTagsString]];
        }
    }
}
- (NSString*)getSelectedTagsString {
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i = 0; i < self.checksOfSections.count; i++) {
        NSArray *checks = self.checksOfSections[i];
        for (int j = 0; j < checks.count; j++) {
            if ([checks[j] boolValue]) {
                [string appendFormat:@"%@%@", [self.valuesOfSections[i][j] label], SEPARATED_TAG_STR];
            }
        }
    }
    return string;
}
- (void)loadTagWithTagType:(NSNumber *)tagType andSelectedTags:(NSArray *)selectTags {
    NSArray *tags = [Tag fetchTagsByType:tagType];
    self.firstCharacters = [[NSMutableArray alloc] init];
    for (Tag *tag in tags) {
        NSString *firstChar = [tag.label substringToIndex:1];
        if (![self.firstCharacters containsObject:firstChar]) {
            [self.firstCharacters addObject:firstChar];
        }
    }
    self.valuesOfSections = [[NSMutableArray alloc] init];
    for (NSString *firstCharacter in self.firstCharacters) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.label beginswith[c] %@", firstCharacter];
        NSMutableArray *valuesOfSection = [[tags filteredArrayUsingPredicate:predicate] mutableCopy];
        [self.valuesOfSections addObject:valuesOfSection];
    }
    
    self.checksOfSections = [[NSMutableArray alloc] init];
    for (NSArray *section in self.valuesOfSections) {
        NSMutableArray *checks = [[NSMutableArray alloc] init];
        for (Tag *tag in section) {
            if ([selectTags containsObject:tag.label]) {
                [checks addObject:@(YES)];
            }
            else {
                [checks addObject:@(NO)];
            }
        }
        [self.checksOfSections addObject:checks];
    }
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
    FESearchTagCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Tag *tag = self.valuesOfSections[indexPath.section][indexPath.row];
    cell.tagName.text = tag.label;
    cell.tagDetail.text = [NSString stringWithFormat:@"(%d)", tag.owner.count];
    cell.tagName.textColor = (tag.owner.count == 0) ? [UIColor darkGrayColor] : [UIColor whiteColor];
    cell.tagDetail.textColor = cell.tagName.textColor;
    BOOL isCheck = [self.checksOfSections[indexPath.section][indexPath.row] boolValue];
    cell.checkMarkView.image = isCheck ? [UIImage imageNamed:@"checkmark"] : nil;
    // change color of letters of sectionIndexTitlesForTableView -> BAD
    for(UIView *view in [tableView subviews]) {
        if([view respondsToSelector:@selector(setIndexColor:)]) {
            [view performSelector:@selector(setIndexColor:) withObject:[UIColor whiteColor]];
        }
    }
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = self.valuesOfSections[indexPath.section][indexPath.row];
    return (tag.owner.count != 0);
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.firstCharacters;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = self.valuesOfSections[indexPath.section][indexPath.row];
    return (tag.owner.count == 0);
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *tags = self.valuesOfSections[indexPath.section];
        NSMutableArray *checks = self.checksOfSections[indexPath.section];
        Tag *tag = tags[indexPath.row];
        
        [tags removeObjectAtIndex:indexPath.row];
        [checks removeObjectAtIndex:indexPath.row];
        if (tags.count == 0) {
            int removeIndex = [self.valuesOfSections indexOfObject:tags];
            [self.valuesOfSections removeObjectAtIndex:removeIndex];
            [self.checksOfSections removeObjectAtIndex:removeIndex];
            [self.firstCharacters removeObjectAtIndex:removeIndex];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        // delete out of database
        [self.indicatorView startAnimating];
        FECoreDataController *coredata = [FECoreDataController sharedInstance];
        [coredata.managedObjectContext deleteObject:tag];
        [coredata saveToPersistenceStoreAndThenRunOnQueue:[NSOperationQueue mainQueue] withFinishBlock:^(NSError *error) {
            [self.indicatorView stopAnimating];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tag *tag = self.valuesOfSections[indexPath.section][indexPath.row];
    if (tag.owner.count == 0) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FESearchTagCell *cell = (FESearchTagCell*)[tableView cellForRowAtIndexPath:indexPath];
    BOOL newCheck = ![self.checksOfSections[indexPath.section][indexPath.row] boolValue];
    self.checksOfSections[indexPath.section][indexPath.row] = @(newCheck);
    cell.checkMarkView.image = newCheck ? [UIImage imageNamed:@"checkmark"] : nil;
}
@end
