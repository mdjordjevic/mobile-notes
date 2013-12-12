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

#define kDatePickerSegueID @"DatePickerSegue_ID"

@interface BaseDetailsViewController () <BaseDetailsDelegate>

@property (nonatomic) EventDataType eventDataType;

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
    [vc didMoveToParentViewController:self];
}

#pragma mark - Public API

- (void)updateDateFromPickerWith:(NSDate *)date
{
    [self.dateButton setTitle:[[NotesAppController sharedInstance].dateFormatter stringFromDate:date]];
}

#pragma mark - Private methods

- (void)updateUI
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.event.time];
    [self.dateButton setTitle:[[NotesAppController sharedInstance].dateFormatter stringFromDate:date]];
}

#pragma mark - Actions

- (IBAction)deleteButtonTouched:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Message.DeleteConfirmation", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(alertView.cancelButtonIndex != buttonIndex)
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
                }
            }];
        }
    }];
}

- (IBAction)doneButtonTouched:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:kDatePickerSegueID])
    {
        DatePickerViewController *dpVC = (DatePickerViewController*)segue.destinationViewController;
        dpVC.baseDetailsVC = self;
    }
}

@end
