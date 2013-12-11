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
- (MeasurementPreviewElement*)previewElement;
- (NSNumber*)valueAsNumber;
- (void)updateMeasurementSets;
- (void)doneButtonTouched:(id)sender;
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
    [self addCustomBackButton];
    
    self.doneButton = [UIBarButtonItem flatBarItemWithImage:[[UIImage imageNamed:@"navbar_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)] text:@"Post" target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    self.valueField.text = @"";
    
    if(self.entry)
    {
        [self updateMeasurementSets];
        [self.typePicker reloadData];
        [self selectRightMeasurementGroupForMeasurementClassKey:self.entry.measurementGroupName andMeasurementType:self.entry.measurementTypeName];
    }
    
    if(self.event)
    {
        [self updateMeasurementSets];
        [self.typePicker reloadData];
        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            [self selectRightMeasurementGroupForMeasurementClassKey:[components objectAtIndex:0] andMeasurementType:[components objectAtIndex:1]];
            NSString *text = [self.event.eventContent description];
            if(!text)
            {
                text = @"";
            }
            self.valueField.text = text;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!self.entry && !self.event)
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
    NSArray *availableSets = [[PYEventTypes sharedInstance] measurementSets];
    
    
    NSMutableDictionary* tempDictionary = [[NSMutableDictionary alloc] init];
    
    for(NSString *setKey in measurementSets)
    {
        for(PYMeasurementSet *set in availableSets)
        {
            if([[set key] isEqualToString:setKey])
            {
                // --- for each event group put them in a new PYGroup
                for (int i = 0; i < set.measurementGroups.count ; i++) {
                    PYEventTypesGroup *pyGroupSrc = [set.measurementGroups objectAtIndex:i];
                    
                    if (! pyGroupSrc.classKey) { continue; }
                    
                    PYEventTypesGroup *pyGroupDest = [tempDictionary objectForKey:pyGroupSrc.classKey];
                    if (! pyGroupDest) {
                        pyGroupDest = [[PYEventTypesGroup alloc] initWithClassKey:pyGroupSrc.classKey
                                                                   andListOfTypes:pyGroupSrc.types andPYEventsTypes:nil];
                        [tempDictionary setObject:pyGroupDest forKey:pyGroupSrc.classKey];
                    } else {
                    // merge arrays
                        for (int j = 0; j < pyGroupSrc.types.count ; j++) {
                            NSString* typeSrc = [pyGroupSrc.types objectAtIndex:j];
                            BOOL found = false;
                            for (int k = 0; k < pyGroupDest.types.count ; k++) {
                                if ([(NSString*)[pyGroupDest.types objectAtIndex:k] isEqualToString:typeSrc]) {
                                    found = true; 
                                }
                            }

                            if (! found) {
                               [pyGroupDest.types addObject:typeSrc];
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    [_measurementGroups addObjectsFromArray:[tempDictionary allValues]];
}

- (void)selectRightMeasurementGroupForMeasurementClassKey:(NSString *)classKey andMeasurementType:(NSString *)measurementType
{
    for(PYEventTypesGroup *mGroup in self.measurementGroups)
    {
        if([mGroup.classKey isEqualToString:classKey])
        {
            [self.typePicker selectRow:[self.measurementGroups indexOfObject:mGroup] inComponent:0 animated:NO];
            for(NSString *type in mGroup.types)
            {
                if([type isEqualToString:measurementType])
                {
                    [self.typePicker selectRow:[mGroup.types indexOfObject:type] inComponent:1 animated:NO];
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
    NSNumber *number = [nf numberFromString:_valueField.text];
    return number;
}

- (MeasurementPreviewElement*)previewElement
{
    MeasurementPreviewElement *element = [[MeasurementPreviewElement alloc] init];
    NSNumber *value = [self valueAsNumber];
    NSInteger selectedGroup = [_typePicker selectedRowInComponent:0];
    NSInteger selectedType = [_typePicker selectedRowInComponent:1];
    PYEventTypesGroup *group = [_measurementGroups objectAtIndex:selectedGroup];
    NSString *type = [group.types objectAtIndex:selectedType];
    element.klass = [group classKey];
    element.format = type;
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
//    _doneButton.enabled = _valueField.text.length > 0;
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
    if([[_valueField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You must enter a value" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
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
