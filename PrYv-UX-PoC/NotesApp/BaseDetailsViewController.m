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

#define kDatePickerSegueID @"DatePickerSegue_ID"
#define kStreamPickerSegue_ID @"StreamPickerSegue_ID"

#define kStreamDefaultConstraint -200
#define kStreamOpenedConstraint 0
#define kTagsDefaultConstraint -200
#define kTagsOpenedConstraint 0

@interface BaseDetailsViewController () <BaseDetailsDelegate,StreamsPickerDelegate>

@property (nonatomic) EventDataType eventDataType;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *streamConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagsConstraint;
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
    [self updateUI];
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
        self.eventDataType = [[DataService sharedInstance] eventDataTypeForEvent:_event];
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
    if(self.shouldUpdateEvent)
    {
        [self showLoadingOverlay];
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
    else
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
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

@end
