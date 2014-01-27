//
//  EventDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "BaseDetailCell.h"
#import "PYEvent+Helper.h"
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYEventType.h>
#import "TextEditorViewController.h"
#import "DatePickerViewController.h"
#import "ImagePreviewViewController.h"
#import "AddNumericalValueViewController.h"
#import "StreamPickerViewController.h"
#import "DataService.h"

#define kValueCellHeight 100
#define kImageCellHeight 320

#define kShowValueEditorSegue @"ShowValueEditorSegue_ID"
#define kShowImagePreviewSegue @"ShowImagePreviewSegue_ID"
#define kShowDatePickerSegue @"kShowDatePickerSegue_ID"
#define kShowTextEditorSegue @"ShowTextEditorSegue_ID"

typedef NS_ENUM(NSUInteger, DetailCellType)
{
    DetailCellTypeValue,
    DetailCellTypeImage,
    DetailCellTypeTime,
    DetailCellTypeDescription,
    DetailCellTypeTags,
    DetailCellTypeStreams
};

@interface EventDetailsViewController () <StreamsPickerDelegate>

@property (nonatomic) BOOL isStreamExpanded;
@property (nonatomic) BOOL isTagExpanded;

@property (nonatomic) BOOL isInEditMode;
@property (nonatomic) BOOL shouldUpdateEvent;

@property (nonatomic, strong) StreamPickerViewController *streamPickerVC;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutletCollection(BaseDetailCell) NSArray *cells;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet UILabel *streamsLabel;

@end

@implementation EventDetailsViewController

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
    
    [self updateUIForEvent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIForEvent
{
    EventDataType eventDataType = [self.event eventDataType];
    if(eventDataType == EventDataTypeImage)
    {
        [self updateUIForEventImageType];
    }
    else if(eventDataType == EventDataTypeValueMeasure)
    {
        [self updateUIForValueEventType];
    }
    else if(eventDataType == EventDataTypeNote)
    {
        [self updateUIForNoteEventType];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.event.time];
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:date];
    self.streamsLabel.text = [self.event eventBreadcrumbsForStreamsList:self.streams];
    self.tagsLabel.text = [self.event.tags componentsJoinedByString:@", "];
    [self.tableView reloadData];
}

- (void)updateUIForEventImageType
{
    if([self.event.attachments count] > 0)
    {
        PYAttachment *att = [self.event.attachments objectAtIndex:0];
        UIImage *img = [UIImage imageWithData:att.fileData];
        self.imageView.image = img;
    }
    self.descriptionLabel.text = self.event.eventDescription;
}

- (void)updateUIForValueEventType
{
    NSString *unit = [self.event.pyType symbol];
    if (! unit) { unit = self.event.pyType.formatKey ; }
    
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[self.event.eventContent description], unit];
    [self.valueLabel setText:value];
    
    NSString *formatDescription = [self.event.pyType localizedName];
    if (! formatDescription) { unit = self.event.pyType.key ; }
    [self.valueTypeLabel setText:formatDescription];
    self.descriptionLabel.text = self.event.eventDescription;
}

- (void)updateUIForNoteEventType
{
    self.descriptionLabel.text = self.event.eventContent;
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCellAtIndexPath:indexPath withEvent:self.event];
}

#pragma mark - UITableViewDeleagate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.isInEditMode)
    {
        return;
    }
    DetailCellType cellType = indexPath.row;
    switch (cellType) {
        case DetailCellTypeValue:
            
            break;
        case DetailCellTypeImage:
            
            break;
        case DetailCellTypeTime:
            
            break;
        case DetailCellTypeDescription:
            break;
        case DetailCellTypeTags:
            
            break;
        case DetailCellTypeStreams:
        {
            StreamPickerViewController *streamPickerVC = [[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"StreamPickerViewController_ID"];
            [self setupStreamPickerViewController:streamPickerVC];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Actions

- (IBAction)editButtonTouched:(id)sender
{
    if(self.isInEditMode)
    {
        if(self.streamPickerVC)
        {
            [self streamPickerShouldClose];
        }
        if(self.shouldUpdateEvent)
        {
            [self updateEvent];
        }
    }
    self.isInEditMode = !self.isInEditMode;
    self.editButton.title = self.isInEditMode ? @"Done" : @"Edit";
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setIsInEditMode:self.isInEditMode];
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return self.isInEditMode;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    if([identifier isEqualToString:kShowTextEditorSegue])
    {
        [self setupTextEditorViewController:segue.destinationViewController];
    }
    else if([identifier isEqualToString:kShowImagePreviewSegue])
    {
        [self setupImagePreviewViewController:segue.destinationViewController];
    }
    else if([identifier isEqualToString:kShowValueEditorSegue])
    {
        [self setupAddNumericalValueViewController:segue.destinationViewController];
    }
    else if([identifier isEqualToString:kShowDatePickerSegue])
    {
        [self setupDatePickerViewController:segue.destinationViewController];
    }
}

#pragma mark - Edit methods

- (void)setupTextEditorViewController:(TextEditorViewController*)textEditorVC
{
    textEditorVC.textDidChangeCallBack = ^(NSString* text, TextEditorViewController* textEdit) {
        if([self.event eventDataType] == EventDataTypeNote)
        {
            if (self.event.eventContent && [text isEqualToString:self.event.eventContent]) return;
            self.shouldUpdateEvent = YES;
            self.event.eventContent = text;
        }
        else
        {
            if (self.event.eventDescription && [text isEqualToString:self.event.eventDescription]) return;
            self.shouldUpdateEvent = YES;
            self.event.eventDescription = text;
        }
        [self updateUIForEvent];
    };
    if([self.event eventDataType] == EventDataTypeNote)
    {
        textEditorVC.text = self.event.eventContent ? self.event.eventContent : @"";
    }
    else
    {
        textEditorVC.text = self.event.eventDescription ? self.event.eventDescription : @"";
    }
}

- (void)setupDatePickerViewController:(DatePickerViewController *)dpVC
{
    dpVC.selectedDate = [NSDate dateWithTimeIntervalSince1970:self.event.time];
    [dpVC setDateDidChangeBlock:^(NSDate *newDate, DatePickerViewController *dp) {
        if([newDate timeIntervalSince1970] == self.event.time) return;
        self.event.time = [newDate timeIntervalSince1970];
        self.shouldUpdateEvent = YES;
        [self updateUIForEvent];
    }];
}

- (void)setupImagePreviewViewController:(ImagePreviewViewController*)imagePreviewVC
{
    if([self.event.attachments count] > 0)
    {
        PYAttachment *att = [self.event.attachments objectAtIndex:0];
        UIImage *img = [UIImage imageWithData:att.fileData];
        imagePreviewVC.image = img;
    }
    imagePreviewVC.descText = self.event.eventDescription;
}

- (void)setupAddNumericalValueViewController:(AddNumericalValueViewController*)addNumericalValueVC
{
    if(self.event.type)
    {
        NSArray *components = [self.event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            addNumericalValueVC.value = [self.event.eventContent description];
            addNumericalValueVC.valueClass = [components objectAtIndex:0];
            addNumericalValueVC.valueType = [components objectAtIndex:1];
        }
    }
    [addNumericalValueVC setValueDidChangeBlock:^(NSString* valueClass, NSString *valueType, NSString* value, AddNumericalValueViewController *addNumericalVC) {
        self.event.eventContent = value;
        self.event.type = [NSString stringWithFormat:@"%@/%@",valueClass,valueType];
        self.shouldUpdateEvent = YES;
        [self updateUIForEvent];
    }];
}

- (void)setupStreamPickerViewController:(StreamPickerViewController*)streamPickerVC
{
    streamPickerVC.event = self.event;
    streamPickerVC.delegate = self;
    self.streamPickerVC = streamPickerVC;
    CGRect frame = self.view.bounds;
    frame.origin.y = frame.size.height;
    frame.size.height = frame.size.height - 100;
    self.streamPickerVC.view.frame = frame;
    [self.view addSubview:streamPickerVC.view];

    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect newFrame = self.streamPickerVC.view.frame;
        newFrame.origin.y = 100;
        self.streamPickerVC.view.frame = newFrame;
    } completion:^(BOOL finished) {
        self.tableView.scrollEnabled = NO;
    }];
}

#pragma mark - StreamPickerDelegate methods

- (void)streamPickerDidSelectStream:(PYStream *)stream
{
    self.event.streamId = stream.streamId;
    self.shouldUpdateEvent = YES;
}

- (void)streamPickerShouldClose
{
    [self updateUIForEvent];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect newFrame = self.streamPickerVC.view.frame;
        newFrame.origin.y = self.view.bounds.size.height;
        self.streamPickerVC.view.frame = newFrame;
    } completion:^(BOOL finished) {
        [self.streamPickerVC.view removeFromSuperview];
        self.streamPickerVC = nil;
        self.tableView.scrollEnabled = YES;
    }];
}

#pragma mark - Utils

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath withEvent:(PYEvent*)event
{
    EventDataType eventDataType = [event eventDataType];
    if(indexPath.row == 0)
    {
        if(eventDataType == EventDataTypeValueMeasure)
        {
            return kValueCellHeight;
        }
        return 0;
    }
    if(indexPath.row == 1)
    {
        if(eventDataType == EventDataTypeImage)
        {
            return kImageCellHeight;
        }
        return 0;
    }
    if(indexPath.row == 3)
    {
        if([self.descriptionLabel.text length] == 0)
        {
            return 0;
        }
        CGSize textSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font constrainedToSize:CGSizeMake(300, FLT_MAX)];
        CGFloat height = textSize.height + 20;
        return fmaxf(height, 54);
    }
    return 54;
}

- (void)saveEvent
{
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil withCompletionBlock:^(PYConnection *connection)
     {
         [connection createEvent:self.event requestType:PYRequestTypeAsync
                  successHandler:^(NSString *newEventId, NSString *stoppedId)
          {
              [[DataService sharedInstance] saveEventAsShortcut:self.event];
              [self.navigationController dismissViewControllerAnimated:YES completion:^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
              }];
          } errorHandler:^(NSError *error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
              [alert show];
          }];
         
     }];
}

- (void)deleteEvent
{
    [self showLoadingOverlay];
    
    [NotesAppController sharedConnectionWithID:nil noConnectionCompletionBlock:nil withCompletionBlock:^(PYConnection *connection)
     {
         [connection trashOrDeleteEvent:self.event withRequestType:PYRequestTypeAsync successHandler:^{
             [self.navigationController popViewControllerAnimated:YES];
             double delayInSeconds = 0.3;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                 [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
             });
         } errorHandler:^(NSError *error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
             [alert show];
             [self hideLoadingOverlay];
         }];
         
     }];
}

- (void)updateEvent
{
    [self showLoadingOverlay];
    [NotesAppController sharedConnectionWithID:nil
                   noConnectionCompletionBlock:nil
                           withCompletionBlock:^(PYConnection *connection)
     {
         [connection setModifiedEventAttributesObject:self.event
                                           forEventId:self.event.eventId
                                          requestType:PYRequestTypeAsync successHandler:^(NSString *stoppedId)
          {
              [self.navigationController popViewControllerAnimated:YES];
              double delayInSeconds = 0.3;
              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
              dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                  [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
              });
          } errorHandler:^(NSError *error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
              [alert show];
              [self hideLoadingOverlay];
          }];
     }];
}

@end
