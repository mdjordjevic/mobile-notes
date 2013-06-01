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

#define kEditEventSegueID @"EditEventSegue_ID"
#define kGroupComponentIndex 0
#define kTypeComponentIndex 1
#define kGroupComponentWidth 100
#define kTypeComponentWidth 150
#define kGroupComponentHeight 100
#define kTypeComponentHeight 44

@interface AddNumericalValueViewController ()

@property (nonatomic, strong) CustomNumericalKeyboard *customKeyborad;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
@property (nonatomic, strong) IBOutlet UITextField *typeTextField;

- (void)updateView:(UIImageView*)view forRow:(NSInteger)row;
- (void)selectFirstTypeAnimated:(BOOL)animated;
- (MeasurementPreviewElement*)previewElement;
- (NSNumber*)valueAsNumber;
- (void)updateMeasurementSets;

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
	self.typePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
    _typePicker.showsSelectionIndicator = NO;
    _typePicker.dataSource = self;
    _typePicker.delegate = self;
    [self.view addSubview:_typePicker];
    
    self.customKeyborad = [[CustomNumericalKeyboard alloc] initWithFrame:CGRectMake(0, 200, 320, 316)];
    _customKeyborad.delegate = self;
    [self textFieldValueChangedForCustomNumericalKeyboard:_customKeyborad];
    [self.view addSubview:_customKeyborad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSInteger groupsCountBeforeUpdate = [_measurementGroups count];
    [self updateMeasurementSets];
    
    [_typePicker reloadAllComponents];
    
    if(groupsCountBeforeUpdate == [_measurementGroups count])
    {
        [_typePicker selectRow:0 inComponent:0 animated:NO];
    }
    [self selectFirstTypeAnimated:NO];
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

- (void)selectFirstTypeAnimated:(BOOL)animated
{
    [_typePicker selectRow:0 inComponent:1 animated:animated];
    [self pickerView:_typePicker didSelectRow:0 inComponent:1];
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

#pragma mark - UIPickerViewDelegate UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        return [_measurementGroups count];
    }
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    return [[[_measurementGroups objectAtIndex:selectedGroup] types] count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        return kGroupComponentWidth;
    }
    return kTypeComponentWidth;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if(component == kTypeComponentIndex)
    {
        return kTypeComponentHeight;
    }
    return kGroupComponentHeight;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if(component == 0)
    {
        UIImageView *viewToReturn = nil;
        if(!view)
        {
            viewToReturn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        }
        else
        {
            viewToReturn = (UIImageView*)view;
        }
        [self updateView:viewToReturn forRow:row];
        return viewToReturn;
    }
    UILabel *label = nil;
    if(!view)
    {
        label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont boldSystemFontOfSize:16]];
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    else
    {
        label = (UILabel*)view;
    }
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    MeasurementGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
    MeasurementType *type = [group.types objectAtIndex:row];
    [label setText:[type localizedName]];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        [_typePicker reloadComponent:1];
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

#pragma mark - CustomNumericalKeyboardDelegate

- (UITextField*)textFieldForCustomkeyboard:(CustomNumericalKeyboard *)customKeybord
{
    return _valueField;
}

- (void)textFieldValueChangedForCustomNumericalKeyboard:(CustomNumericalKeyboard *)customKeyboard
{
    _addButton.enabled = _valueField.text.length > 0;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kEditEventSegueID])
    {
        EditEventViewController *editEventVC = (EditEventViewController*)[segue destinationViewController];
        MeasurementPreviewElement *previewElement = [self previewElement];
        editEventVC.eventElement = previewElement;
    }
}

@end
