//
//  AddNumericalValueViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/19/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AddNumericalValueViewController.h"
#import "MeasurementSet.h"
#import "MeasurementController.h"
#import "EditEventViewController.h"
#import "MeasurementPreviewElement.h"
#import "KSAdvancedPicker.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"

#define kSaveMeasurementSegue @"SaveMeasurementSegue_ID"
#define kGroupComponentIndex 0
#define kTypeComponentIndex 1
#define kGroupComponentWidth 120
#define kTypeComponentWidth 200
#define kGroupComponentHeight 77

@interface AddNumericalValueViewController () <KSAdvancedPickerDataSource, KSAdvancedPickerDelegate>

@property (nonatomic, strong) IBOutlet CustomNumericalKeyboard *customKeyborad;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
@property (nonatomic, strong) IBOutlet UITextField *typeTextField;
@property (nonatomic, strong) IBOutlet KSAdvancedPicker *typePicker;

- (void)updateView:(UIImageView*)view forRow:(NSInteger)row;
- (void)selectFirstTypeAnimated:(BOOL)animated;
- (MeasurementPreviewElement*)previewElement;
- (NSNumber*)valueAsNumber;
- (void)updateMeasurementSets;
- (void)doneButtonTouched:(id)sender;
- (void)selectRightMeasurementGroup;

@end

@implementation AddNumericalValueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self textFieldValueChangedForCustomNumericalKeyboard:_customKeyborad];
    self.typePicker.delegate = self;
    self.typePicker.dataSource = self;
    [self.typePicker reloadData];
    UIButton *delBtn = (UIButton*)[self.customKeyborad viewWithTag:11];
    [delBtn setTitle:@"\u232B" forState:UIControlStateNormal];
    [self addCustomBackButton];
    
    self.doneButton = [UIBarButtonItem flatBarItemWithImage:[[UIImage imageNamed:@"navbar_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)] text:@"Done" target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    if(self.entry)
    {
        [self updateMeasurementSets];
        [self.typePicker reloadData];
        [self selectRightMeasurementGroup];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!self.entry)
    {
        NSInteger groupsCountBeforeUpdate = [_measurementGroups count];
        [self updateMeasurementSets];
        
        [self.typePicker reloadData];
        
        if(groupsCountBeforeUpdate == [_measurementGroups count])
        {
            [_typePicker selectRow:0 inComponent:0 animated:NO];
        }
        [self selectFirstTypeAnimated:NO];
    }
}

- (void)updateMeasurementSets
{
    if(self.measurementGroups)
    {
        [self.measurementGroups removeAllObjects];
    }
    else
    {
        self.measurementGroups = [NSMutableArray array];
    }
    NSArray *measurementSets = [[MeasurementController sharedInstance] userSelectedMeasurementSets];
    NSArray *availableSets = [[MeasurementController sharedInstance] availableMeasurementSets];
    for(NSString *setKey in measurementSets)
    {
        for(MeasurementSet *set in availableSets)
        {
            if([[set key] isEqualToString:setKey])
            {
                [_measurementGroups addObjectsFromArray:set.measurementGroups];
            }
        }
        
    }
}

- (void)selectRightMeasurementGroup
{
    for(MeasurementGroup *mGroup in self.measurementGroups)
    {
        if(([mGroup.name isEqualToString:@"mass"] && self.entry.dataType == CellStyleTypeMass) ||
           ([mGroup.name isEqualToString:@"length"] && self.entry.dataType == CellStyleTypeLength) ||
           ([mGroup.name isEqualToString:@"money"] && self.entry.dataType == CellStyleTypeMoney))
        {
            [self.typePicker selectRow:[self.measurementGroups indexOfObject:mGroup] inComponent:0 animated:NO];
            break;
        }
    }
}

- (void)selectFirstTypeAnimated:(BOOL)animated
{
    [_typePicker selectRow:0 inComponent:1 animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView:(UIImageView *)view forRow:(NSInteger)row
{
    MeasurementGroup *group = [_measurementGroups objectAtIndex:row];
    [view setImage:[UIImage imageNamed:[group name]]];
}

- (NSNumber*)valueAsNumber
{
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *number = [nf numberFromString:_valueField.text];
    return number;
}

- (MeasurementPreviewElement*)previewElement
{
    MeasurementPreviewElement *element = [[MeasurementPreviewElement alloc] init];
    NSNumber *value = [self valueAsNumber];
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    NSInteger selectedType = [_typePicker selectedRowInComponent:1];
    MeasurementGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
    MeasurementType *type = [group.types objectAtIndex:selectedType];
    element.klass = [group name];
    element.format = [type mark];
    element.value = value;
    
    return element;
}

#pragma mark - CustomNumericalKeyboardDelegate

- (UITextField*)textFieldForCustomkeyboard:(CustomNumericalKeyboard *)customKeybord
{
    return _valueField;
}

- (void)textFieldValueChangedForCustomNumericalKeyboard:(CustomNumericalKeyboard *)customKeyboard
{
    _doneButton.enabled = _valueField.text.length > 0;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kSaveMeasurementSegue])
    {
        EditEventViewController *editEventVC = (EditEventViewController*)[segue destinationViewController];
        MeasurementPreviewElement *previewElement = [self previewElement];
        editEventVC.eventElement = previewElement;
        editEventVC.entry = self.entry;
    }
}

- (void)doneButtonTouched:(id)sender
{
    [self performSegueWithIdentifier:kSaveMeasurementSegue sender:self];
}

#pragma mark - KSAdvancedPickerDataSource and KSAdvancedDelegate methods

- (NSInteger) numberOfComponentsInAdvancedPicker:(KSAdvancedPicker *)picker
{
    return 2;
}

- (NSInteger) advancedPicker:(KSAdvancedPicker *)picker numberOfRowsInComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        return [_measurementGroups count];
    }
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    return [[[_measurementGroups objectAtIndex:selectedGroup] types] count];
}

- (UIView *) advancedPicker:(KSAdvancedPicker *)picker viewForComponent:(NSInteger)component inRect:(CGRect)rect
{
    if(component == kGroupComponentIndex)
    {
        UIImageView *viewToReturn = [[UIImageView alloc] initWithFrame:rect];
        viewToReturn.contentMode = UIViewContentModeCenter;
        return viewToReturn;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont boldSystemFontOfSize:24]];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (void) advancedPicker:(KSAdvancedPicker *)picker setDataForView:(UIView *)view row:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        UIImageView *imgView = (UIImageView*)view;
        [self updateView:imgView forRow:row];
    }
    else
    {
        UILabel *label = (UILabel*)view;
        NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
        MeasurementGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        MeasurementType *type = [group.types objectAtIndex:row];
        [label setText:[type localizedName]];
    }
}

- (CGFloat)heightForRowInAdvancedPicker:(KSAdvancedPicker *)picker
{
    return kGroupComponentHeight;
}

- (CGFloat) advancedPicker:(KSAdvancedPicker *)picker widthForComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        return kGroupComponentWidth;
    }
    return kTypeComponentWidth;
}

- (void) advancedPicker:(KSAdvancedPicker *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        [self.typePicker reloadDataInComponent:1];
        [self selectFirstTypeAnimated:YES];
    }
    else if(component == 1)
    {
        NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
        MeasurementGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        MeasurementType *type = [group.types objectAtIndex:row];
        [_typeTextField setText:[type mark]];
    }
}

- (UIColor *) backgroundColorForAdvancedPicker:(KSAdvancedPicker *)picker
{
    return [UIColor clearColor];
}

- (UIColor *) advancedPicker:(KSAdvancedPicker *)picker backgroundColorForComponent:(NSInteger)component
{
    return [UIColor clearColor];
}

- (UIColor *) overlayColorForAdvancedPickerSelector:(KSAdvancedPicker *)picker
{
    return [UIColor clearColor];
}

- (UIColor *) viewColorForAdvancedPickerSelector:(KSAdvancedPicker *)picker
{
    return [UIColor clearColor];
}

@end
