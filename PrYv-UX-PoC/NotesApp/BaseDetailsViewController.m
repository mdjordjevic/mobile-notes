//
//  BaseDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 12/2/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BaseDetailsViewController.h"
#import "BaseContentViewController.h"
#import "PYEvent+Helper.h"
#import "DataService.h"
#import "UIAlertView+PrYv.h"
#import "DatePickerViewController.h"
#import "StreamPickerViewController.h"
#import "TextEditorViewController.h"
#import "JSTokenField.h"
#import "JSTokenButton.h"

#define kDatePickerSegueID @"DatePickerSegue_ID"
#define kStreamPickerSegue_ID @"StreamPickerSegue_ID"

#define kStreamDefaultConstraint -200
#define kStreamOpenedConstraint 0
#define kTagsDefaultConstraint -200
#define kTagsOpenedConstraint 0

@interface BaseDetailsViewController () <BaseDetailsDelegate,StreamsPickerDelegate,JSTokenFieldDelegate>

@property (nonatomic) EventDataType eventDataType;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *streamConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *doneButtonConstraint;
@property (nonatomic, strong) StreamPickerViewController *streamPicker;
@property (nonatomic, strong) BaseContentViewController *contentDetailsVC;
@property (nonatomic) BOOL shouldUpdateEvent;

@end

@implementation BaseDetailsViewController

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
    self.shouldUpdateEvent = NO;
	[self setupContentViewController];
    [self initTags];
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEvent:(PYEvent *)event
{
    if(![_event isEqual:event])
    {
        _event = event;
        if(!self.isEditing && !_event.type)
        {
            self.eventDataType = EventDataTypeValueMeasure;
        }
        else
        {
            self.eventDataType = [[DataService sharedInstance] eventDataTypeForEvent:_event];
        }
    }
}

- (void)initTags
{
    self.tagsField.delegate = self;
    self.doneButtonConstraint.constant = 0;
    [self.view layoutIfNeeded];
    for(NSString *tag in self.event.tags)
    {
        [self.tagsField addTokenWithTitle:tag representedObject:tag];
    }
    if([self.event.tags count] == 0)
    {
        self.tagsField.textField.placeholder = NSLocalizedString(@"ViewController.Tags.TapToAdd", nil);
    }
}

- (void)setupContentViewController
{
    BaseContentViewController *vc = nil;
    switch (_eventDataType) {
        case EventDataTypeNote:
            vc = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"NoteDetailsViewController_ID"];
            break;
        case EventDataTypeValueMeasure:
            vc = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"ValueDetailsViewController_ID"];
            break;
        case EventDataTypeImage:
            vc = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"ImageDetailsViewController_ID"];
            break;
            
        default:
            break;
    }
    vc.delegate = self;
    vc.isEditing = self.isEditing;
    vc.event = self.event;
    [self addChildViewController:vc];
    vc.view.frame = self.detailsContainerView.bounds;
    [self.detailsContainerView addSubview:vc.view];
    self.contentDetailsVC = vc;
    [vc didMoveToParentViewController:self];
}

#pragma mark - Public API

- (void)updateDateFromPickerWith:(NSDate *)date
{
    [self.dateButton setTitle:[[NotesAppController sharedInstance].dateFormatter stringFromDate:date]];
    self.event.time = [date timeIntervalSince1970];
    self.shouldUpdateEvent = YES;
}

#pragma mark - Private methods

- (void)updateUI
{
    if(!self.isEditing)
    {
        self.event.time = [[NSDate new] timeIntervalSince1970];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.event.time];
    [self.dateButton setTitle:[[NotesAppController sharedInstance].dateFormatter stringFromDate:date]];
}

- (void)deleteCurrentEvent
{
    [self showLoadingOverlay];
    [[DataService sharedInstance] deleteEvent:self.event withCompletionBlock:^(id object, NSError *error) {
        [self hideLoadingOverlay];
        if(error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
            }];
        }
    }];
}

- (void)updateEvent
{
    [[DataService sharedInstance] updateEvent:self.event withCompletionBlock:^(id object, NSError *error) {
        [self hideLoadingOverlay];
        if(error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
            }];
        }
    }];
}

- (void)saveEvent
{
    [[DataService sharedInstance] saveEvent:self.event withCompletionBlock:^(id object, NSError *error) {
        [self hideLoadingOverlay];
        if(error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
            }];
        }
    }];
}

#pragma mark - Actions

- (IBAction)deleteButtonTouched:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Message.DeleteConfirmation", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(alertView.cancelButtonIndex != buttonIndex)
        {
            [self deleteCurrentEvent];
        }
    }];
}

- (IBAction)doneButtonTouched:(id)sender
{
    
    if(! self.event.streamId)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please select a stream" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [self changeVisibilityOfStreamPickerTo:YES];
        return;
    }

    
    if(self.shouldUpdateEvent)
    {
        [self showLoadingOverlay];
        if(self.isEditing)
        {
            [self updateEvent];
        }
        else
        {
            [self saveEvent];
        }
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)doneTagsEditingButtonTouched:(id)sender
{
    [self.tagsField.textField resignFirstResponder];
    [self.tagsField updateTokensInTextField:self.tagsField.textField];
    NSMutableArray *tokens = [NSMutableArray array];
    for(JSTokenButton *token in self.tagsField.tokens)
    {
        [tokens addObject:[token representedObject]];
    }
    self.event.tags = tokens;
    self.shouldUpdateEvent = YES;
}

#pragma mark - JSTOkenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    if([tokenField.tokens count] == 0)
    {
        self.tagsField.textField.placeholder = @"Tap to add tags";
    }
    else
    {
        self.tagsField.textField.placeholder = @"";
    }
    return NO;
}

- (void)tokenFieldWillBeginEditing:(JSTokenField *)tokenField
{
    
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField
{
    
}

#pragma mark - StreamPickerDelegate methods

- (void)changeVisibilityOfStreamPickerTo:(BOOL)visible
{
    if(visible)
    {
        self.streamConstraint.constant = kStreamOpenedConstraint;
    }
    else
    {
        self.streamConstraint.constant = kStreamDefaultConstraint;
    }
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)streamSelected:(PYStream *)stream
{
    self.event.streamId = stream.streamId;
    self.shouldUpdateEvent = YES;
}

#pragma mark - BaseDetailsDelegate methods

- (void)textDidChangedTo:(NSString *)newText
{
    self.event.eventContent = newText;
    [self.contentDetailsVC updateEventDetails];
    self.shouldUpdateEvent = YES;
}

- (void)eventDidChangeProperties:(NSString *)valueClass valueType:(NSString *)valueType value:(NSString *)value
{
    self.event.eventContent = value;
    self.event.type = [NSString stringWithFormat:@"%@/%@",valueClass,valueType];
    self.shouldUpdateEvent = YES;
    [self.contentDetailsVC updateEventDetails];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kDatePickerSegueID])
    {
        DatePickerViewController *dpVC = (DatePickerViewController*)segue.destinationViewController;
        dpVC.baseDetailsVC = self;
    }
    else if([segue.identifier isEqualToString:kStreamPickerSegue_ID])
    {
        StreamPickerViewController *streamPicker = (StreamPickerViewController*)segue.destinationViewController;
        streamPicker.event = self.event;
        streamPicker.delegate = self;
        self.streamPicker = streamPicker;
    }
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.tagsContainerConstraint.constant = keyboardSize.height - 44;
    self.doneButtonConstraint.constant = 80;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.doneTagsEditingButton setWidth:37];
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tagsContainerConstraint.constant = 0;
    self.doneButtonConstraint.constant = 0;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
