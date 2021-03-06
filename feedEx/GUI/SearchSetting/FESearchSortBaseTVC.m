//
//  FESearchSortBaseTVC.m
//  feedEx
//
//  Created by csnguyen on 6/23/13.
//  Copyright (c) 2013 csnguyen. All rights reserved.
//

#import "FESearchSortBaseTVC.h"
#import "FEActionSheetPicker.h"
#import "FESearchTagVC.h"

@interface FESearchSortBaseTVC () <UITextFieldDelegate, FEActionSheetPickerDelegate, FESearchTagVCDelegate>

@end

@implementation FESearchSortBaseTVC
#define OPEN_TAG_SELECTION @"openTagsSelection"
#define SORT_STRING_FORMAT  @"%@-%@"
#define TYPE_WIDTH 160
#define DIRECTION_WIDTH 420 - TYPE_WIDTH
- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstSortTF.delegate = self;
    self.secondSortTF.delegate = self;
    self.tagsTF.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:OPEN_TAG_SELECTION]) {
        FESearchTagVC *searchTagVC = [segue destinationViewController];
        searchTagVC.delegate = self;
        NSArray *selectedTags = ((self.tagsTF.text.length == 0) ? @[] : [self.tagsTF.text componentsSeparatedByString:SEPARATED_TAG_STR]);
        [searchTagVC loadTagWithTagType:self.tagType andSelectedTags:selectedTags];
    }
}

#pragma mark - getter setter
- (NSArray*)getTypeStrings {
    // abstract
    return nil;
}

#define FIRST_SORT_TAG  0
#define SECOND_SORT_TAG 1
- (FEActionSheetPicker*)buildASPFromSortString:(NSString*)sortStr withExceptTypeString:(NSString*)exceptTypeStr{
    NSMutableArray *types = [NSMutableArray arrayWithArray:[self getTypeStrings]];
    NSArray *directions = DIRECTION_STRING_LIST;
    for (NSString *type in types) {
        if ([type isEqualToString:exceptTypeStr]) {
            [types removeObject:type];
            break;
        }
    }
    
    NSUInteger selectedTypeId = 0;
    NSUInteger selectedDirectionId = 0;
    if (sortStr.length != 0) {
        NSArray *separatedStrs = [sortStr componentsSeparatedByString:SEPARATED_SORT_STR];
        for (int i = 0; i < types.count; i++) {
            if ([types[i] isEqualToString:separatedStrs[0]]) {
                selectedTypeId = i;
                break;
            }
        }
        for (int i = 0; i < directions.count; i++) {
            if ([directions[i] isEqualToString:separatedStrs[1]]) {
                selectedDirectionId = i;
                break;
            }
        }
    }
    
    NSArray *columns = @[[[FEActionSheetPickerElement alloc] initWithSelectedId:selectedTypeId width:TYPE_WIDTH rows:types],
                         [[FEActionSheetPickerElement alloc] initWithSelectedId:selectedDirectionId width:DIRECTION_WIDTH rows:directions]];
    return [[FEActionSheetPicker alloc] initWithTitle:@"Select Sort type" columns:columns delegate:self origin:self.view];
}
- (void)setFirstSortText:(NSString*)firstSort andSecondSortText:(NSString*)secondSort {
    self.firstSortTF.text = firstSort;
    if (firstSort.length == 0) {
        [self setEnableSecondSort:NO];
    }
    else {
        self.secondSortTF.text = secondSort;
    }
}
- (void)setEnableSecondSort:(BOOL)enable {
    self.secondSortTF.enabled = enable;
    if (self.firstSortTF.text.length > 0) {
        self.secondSortTF.placeholder = @"Tap to select sort condition";
    }
    else {
        self.secondSortTF.placeholder = @"Select 1st sort firstly";
    }
}
#pragma mark - Action handle
- (IBAction)firstSortTapped:(UITextField *)sender {
    FEActionSheetPicker *asp = [self buildASPFromSortString:sender.text withExceptTypeString:@""];
    asp.tag = FIRST_SORT_TAG;
    [asp showActionSheetPicker];
}
- (IBAction)secondSortTapped:(UITextField *)sender {
    if (sender.enabled == NO) {
        return;
    }
    NSArray *separatedStrs = [self.firstSortTF.text componentsSeparatedByString:SEPARATED_SORT_STR];
    FEActionSheetPicker *asp = [self buildASPFromSortString:sender.text
                                       withExceptTypeString:(separatedStrs.count != 0) ? separatedStrs[0] : @""];
    asp.tag = SECOND_SORT_TAG;
    [asp showActionSheetPicker];
}
- (IBAction)tagsTapped:(UITextField *)sender {
    [self performSegueWithIdentifier:OPEN_TAG_SELECTION sender:sender];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.firstSortTF) {
        [self setEnableSecondSort:NO];
        self.secondSortTF.text = @"";
    }
    textField.text = @"";
    return NO;
}
#pragma mark - FEActionSheetPickerDelegate
- (void)didSelectPicker:(FEActionSheetPicker *)asp {
    NSString *typeStr = [asp.columns[0] rows][[asp.columns[0] selectedId]];
    NSString *directionStr = [asp.columns[1] rows][[asp.columns[1] selectedId]];;
    if (asp.tag == FIRST_SORT_TAG) {
        self.firstSortTF.text = [NSString stringWithFormat:SORT_STRING_FORMAT, typeStr, directionStr];
        [self setEnableSecondSort:YES];
        // if first sort reselect second sort then remove second sort
        if (self.secondSortTF.text.length > 0) {
            NSArray *separatedStrs = [self.secondSortTF.text componentsSeparatedByString:SEPARATED_SORT_STR];
            if ([typeStr isEqualToString:separatedStrs[0]]) {
                self.secondSortTF.text = @"";
            }
        }
    }
    else {
        self.secondSortTF.text = [NSString stringWithFormat:SORT_STRING_FORMAT, typeStr, directionStr];
    }
    
}
- (void)didCancelPicker:(FEActionSheetPicker *)asp {
    
}
#pragma mark - FESearchTagVCDelegate
- (void)didSelectTags:(NSString *)selectedTagsString {
    self.tagsTF.text = selectedTagsString;
}
@end
