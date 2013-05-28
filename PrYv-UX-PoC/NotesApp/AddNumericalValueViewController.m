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

@interface AddNumericalValueViewController ()

@property (nonatomic, strong) CustomNumericalKeyboard *customKeyborad;
@property (nonatomic, strong) NSMutableArray *measurementGroups;

- (void)updateView:(UIView*)view forRow:(NSInteger)row;

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
    [self.view addSubview:_customKeyborad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    [_typePicker reloadAllComponents];
    [_typePicker selectRow:0 inComponent:0 animated:NO];
    [_typePicker selectRow:0 inComponent:1 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView:(UIView *)view forRow:(NSInteger)row
{
    switch (row) {
        case 0:
            [view setBackgroundColor:[UIColor redColor]];
            break;
        case 1:
            [view setBackgroundColor:[UIColor greenColor]];
            break;
        case 2:
            [view setBackgroundColor:[UIColor blueColor]];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIPickerViewDelegate UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [_measurementGroups count];
    }
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    return [[_measurementGroups[selectedGroup] types] count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if(component == 0)
    {
        return 100;
    }
    return 150;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    if(component == 1)
    {
        return 44;
    }
    return 100;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
//    if(component == 0)
//    {
//        UIView *viewToReturn = nil;
//        if(!view)
//        {
//            viewToReturn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//        }
//        else
//        {
//            viewToReturn = view;
//        }
//        [self updateView:viewToReturn forRow:row];
//        return viewToReturn;
//    }
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
    if(component == 0)
    {
        MeasurementGroup *group = _measurementGroups[row];
        [label setText:[group name]];
    }
    else
    {
        NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
        MeasurementGroup *group = _measurementGroups[selectedGroup];
        MeasurementType *type = group.types[row];
        [label setText:[type localizedName]];
    }
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        [_typePicker reloadComponent:1];
    }
}

#pragma mark - CustomNumericalKeyboardDelegate

- (UITextField*)textFieldForCustomkeyboard:(CustomNumericalKeyboard *)customKeybord
{
    return _valueField;
}

@end
