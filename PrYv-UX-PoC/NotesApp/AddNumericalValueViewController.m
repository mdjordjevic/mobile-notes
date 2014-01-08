//
//  AddNumericalValueViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/19/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "AddNumericalValueViewController.h"
#import <PryvApiKit/PYMeasurementSet.h>
#import <PryvApiKit/PYEventTypes.h>
#import <PryvApiKit/PYEventTypesGroup.h>
#import "MeasurementController.h"
#import "EditEventViewController.h"
#import "MeasurementPreviewElement.h"
#import "KSAdvancedPicker.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"
#import "AddNumericalValueCellFormat.h"
#import "AddNumericalValueCellClass.h"

#define kSaveMeasurementSegue @"SaveMeasurementSegue_ID"
#define kGroupComponentIndex 0
#define kTypeComponentIndex 1
#define kGroupComponentProportionalWidth 0.5
#define kGroupComponentHeight 77

@interface AddNumericalValueViewController () <KSAdvancedPickerDataSource, KSAdvancedPickerDelegate>

@property (nonatomic, strong) IBOutlet CustomNumericalKeyboard *customKeyborad;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
@property (nonatomic, strong) IBOutlet UITextField *typeTextField;
@property (nonatomic, strong) IBOutlet KSAdvancedPicker *typePicker;

- (void)updateView:(UIImageView*)view forRow:(NSInteger)row;
- (void)selectFirstTypeAnimated:(BOOL)animated;
- (NSNumber*)valueAsNumber;
- (void)updateMeasurementSets;
- (void)selectRightMeasurementGroupForMeasurementClassKey:(NSString*)classKey andMeasurementType:(NSString*)measurementType;

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
    
    self.valueField.text = @"";
    
    [self updateMeasurementSets];
    [self.typePicker reloadData];
    [self selectRightMeasurementGroupForMeasurementClassKey:self.valueClass andMeasurementType:self.valueType];
    if(self.value)
    {
        self.valueField.text = self.value;
    }
    
//    if(self.entry)
//    {
//        [self updateMeasurementSets];
//        [self.typePicker reloadData];
//        [self selectRightMeasurementGroupForMeasurementClassKey:self.entry.measurementGroupName andMeasurementType:self.entry.measurementTypeName];
//    }
//    
//    if(self.event)
//    {
//        [self updateMeasurementSets];
//        [self.typePicker reloadData];
//        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
//        if([components count] > 1)
//        {
//            [self selectRightMeasurementGroupForMeasurementClassKey:[components objectAtIndex:0] andMeasurementType:[components objectAtIndex:1]];
//            NSString *text = [self.event.eventContent description];
//            if(!text)
//            {
//                text = @"";
//            }
//            self.valueField.text = text;
//        }
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if(!self.entry && !self.event)
//    {
//        NSInteger groupsCountBeforeUpdate = [_measurementGroups count];
//        [self updateMeasurementSets];
//        
//        [self.typePicker reloadData];
//        
//        if(groupsCountBeforeUpdate == [_measurementGroups count])
//        {
//            [_typePicker selectRow:0 inComponent:0 animated:NO];
//        }
//        [self selectFirstTypeAnimated:NO];
//    }
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
    NSArray *availableSets = [[PYEventTypes sharedInstance] measurementSets];
    
    
    NSMutableDictionary* tempDictionary = [[NSMutableDictionary alloc] init];
    
    
    
    for(NSString *setKey in measurementSets) // for each set choosen by the user
    {
        for(PYMeasurementSet *set in availableSets) // for each available set
        {
            if([[set key] isEqualToString:setKey]) // found set in available set
            {
                // --- for each event group put them in a new PYGroup
                for (int i = 0; i < set.measurementGroups.count ; i++) {
                    PYEventTypesGroup *pyGroupSrc = [set.measurementGroups objectAtIndex:i];
                    
                    if (! pyGroupSrc.classKey) { continue; } // should not happend
                    
                    PYEventTypesGroup *pyGroupDest = [tempDictionary objectForKey:pyGroupSrc.classKey];
                    if (! pyGroupDest) {
                        pyGroupDest = [[PYEventTypesGroup alloc] initWithClassKey:pyGroupSrc.classKey
                                                                 andListOfFormats:pyGroupSrc.formatKeyList
                                                                 andPYEventsTypes:nil];
                        [tempDictionary setObject:pyGroupDest forKey:pyGroupSrc.classKey];
                    } else {
                    // merge
                        [pyGroupDest addFormats:pyGroupSrc.formatKeyList withClassKey:pyGroupSrc.classKey];
                    }
                    [pyGroupDest sortUsingLocalizedName];
                }
                
            }
        }
    }
    
    
   
    [_measurementGroups addObjectsFromArray:[tempDictionary allValues]];
    
    // order
    [_measurementGroups sortUsingComparator:^NSComparisonResult(id a, id b) {
        return [[(PYEventTypesGroup*)a localizedName] caseInsensitiveCompare:[(PYEventTypesGroup*)b localizedName]];
    }];
    
}

- (void)selectRightMeasurementGroupForMeasurementClassKey:(NSString *)classKey andMeasurementType:(NSString *)measurementType
{
    for(PYEventTypesGroup *mGroup in self.measurementGroups)
    {
        if([mGroup.classKey isEqualToString:classKey])
        {
            [self.typePicker selectRow:[self.measurementGroups indexOfObject:mGroup] inComponent:0 animated:NO];
            for(NSString *type in mGroup.formatKeys)
            {
                if([type isEqualToString:measurementType])
                {
                    [self.typePicker selectRow:[mGroup.formatKeys indexOfObject:type] inComponent:1 animated:NO];
                    return;
                }
            }
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
    PYEventTypesGroup *group = [_measurementGroups objectAtIndex:row];
    [view setImage:[UIImage imageNamed:[group classKey]]];
}

- (NSNumber*)valueAsNumber
{
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setMaximumFractionDigits:2000];
    NSNumber *number = [nf numberFromString:_valueField.text];
    return number;
}

//- (MeasurementPreviewElement*)previewElement
//{
//    MeasurementPreviewElement *element = [[MeasurementPreviewElement alloc] init];
//    NSNumber *value = [self valueAsNumber];
//    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
//    NSInteger selectedType = [_typePicker selectedRowInComponent:1];
//    PYEventTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
//    NSString *formatKey = [group.formatKeys objectAtIndex:selectedType];
//    element.klass = [group classKey];
//    element.format = formatKey;
//    element.value = value;
//
//    return element;
//}

#pragma mark - CustomNumericalKeyboardDelegate

- (UITextField*)textFieldForCustomkeyboard:(CustomNumericalKeyboard *)customKeybord
{
    return _valueField;
}

- (void)textFieldValueChangedForCustomNumericalKeyboard:(CustomNumericalKeyboard *)customKeyboard
{
//    _doneButton.enabled = _valueField.text.length > 0;
}

#pragma mark - Segues

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([segue.identifier isEqualToString:kSaveMeasurementSegue])
//    {
//        EditEventViewController *editEventVC = (EditEventViewController*)[segue destinationViewController];
//        MeasurementPreviewElement *previewElement = [self previewElement];
//        editEventVC.eventElement = previewElement;
//        editEventVC.entry = self.entry;
//    }
//}

- (IBAction)doneButtonTouched:(id)sender
{
    NSLog(@"");
    if([[_valueField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 1)
    {
        _valueField.text = @"0";
    }
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    NSInteger selectedType = [_typePicker selectedRowInComponent:1];
    PYEventTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
    NSString *formatKey = [group.formatKeys objectAtIndex:selectedType];
    [self.delegate eventDidChangeProperties:[group classKey] valueType:formatKey value:_valueField.text];
    [self.navigationController popViewControllerAnimated:YES];
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
    return [[[_measurementGroups objectAtIndex:selectedGroup] formatKeys] count];
}

- (UIView *) advancedPicker:(KSAdvancedPicker *)picker viewForComponent:(NSInteger)component inRect:(CGRect)rect
{
    if(component == kGroupComponentIndex)
    {
        //UILabel *label = [[UILabel alloc] initWithFrame:rect];
        //[label setBackgroundColor:[UIColor clearColor]];
        //[label setFont:[UIFont boldSystemFontOfSize:24]];
        //[label setTextAlignment:UITextAlignmentCenter];
        //return label;
        
        AddNumericalValueCellClass *cell = [[AddNumericalValueCellClass alloc] initWithFrame:rect];
        return cell ;
    }
    
    AddNumericalValueCellFormat *cell = [[AddNumericalValueCellFormat alloc] initWithFrame:rect];
    return cell;
    
}

- (void) advancedPicker:(KSAdvancedPicker *)picker setDataForView:(UIView *)view row:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == kGroupComponentIndex)
    {
        //UILabel *label = (UILabel*)view;
        UILabel *label = [(AddNumericalValueCellClass*)view classLabel];
        
        PYEventTypesGroup *group = [_measurementGroups objectAtIndex:row];
        [label setText:group.localizedName];
        
        
    }
    else
    {
       
        
        NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
        PYEventTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        
        PYEventType *pyType = [group pyTypeAtIndex:row];
        NSString *symbolText = pyType.type;
        
        NSString *nameText = @"";
        if (pyType && pyType.localizedName) {
            nameText = pyType.localizedName;
        }
        if (pyType && pyType.symbol) {
            symbolText = pyType.symbol;
        }
        
        
        
        AddNumericalValueCellFormat *cell = (AddNumericalValueCellFormat*)view;
        [cell.nameLabel setText:nameText];
        [cell.symbolLabel setText:symbolText];
    }
}

- (CGFloat)heightForRowInAdvancedPicker:(KSAdvancedPicker *)picker
{
    return kGroupComponentHeight;
}

- (CGFloat) advancedPicker:(KSAdvancedPicker *)picker widthForComponent:(NSInteger)component
{
    CGFloat width = picker.frame.size.width;
    if(component == kGroupComponentIndex)
    {
        return width * kGroupComponentProportionalWidth;
    }
    //return width * (1 - kGroupComponentProportionalWidth);
    // TODO Fix.. there is a problem with the width of 2nd column component
    return 320;
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
        PYEventTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
        PYEventType *pyType = [group pyTypeAtIndex:row];
        NSString *descLabel = pyType.key;
        if (pyType && pyType.symbol) {
            descLabel = pyType.symbol;
        }

        [_typeTextField setText:descLabel];
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
