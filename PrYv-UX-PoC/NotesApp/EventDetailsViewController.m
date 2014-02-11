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
#import <PryvApiKit/PYConnection+TimeManagement.h>
#import <PryvApiKit/PYEventTypes.h>
#import "TextEditorViewController.h"
#import "DatePickerViewController.h"
#import "ImagePreviewViewController.h"
#import "AddNumericalValueViewController.h"
#import "StreamPickerViewController.h"
#import "DataService.h"
#import "JSTokenField.h"
#import "JSTokenButton.h"
#import "DetailsBottomButtonsContainer.h"
#import "UIAlertView+PrYv.h"

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

@interface EventDetailsViewController () <StreamsPickerDelegate,JSTokenFieldDelegate>

@property (nonatomic) BOOL isStreamExpanded;
@property (nonatomic) BOOL isTagExpanded;

@property (nonatomic) BOOL isInEditMode;
@property (nonatomic) BOOL shouldUpdateEvent;

@property (nonatomic, strong) StreamPickerViewController *streamPickerVC;
@property (nonatomic, strong) NSMutableDictionary *eventDictionary;
@property (nonatomic) EventDataType eventDataType;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutletCollection(BaseDetailCell) NSArray *cells;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet JSTokenField *tokenField;
@property (nonatomic, weak) IBOutlet UIButton *tokendDoneButton;
@property (nonatomic, weak) IBOutlet UIView *tokenContainer;
@property (nonatomic, weak) IBOutlet UILabel *streamsLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tagDoneButtonConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint1;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint2;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionLabelConstraint3;
@property (nonatomic, strong) DetailsBottomButtonsContainer *bottomButtonsContainer;

- (BOOL) shouldCreateEvent;

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
    
    [UI7NavigationController patchIfNeeded];
    [UI7NavigationItem patchIfNeeded];
    [UI7NavigationBar patchIfNeeded];
    
    if(self.event)
    {
        [self updateEventDataType];
    }
    
    if(self.isNewEvent)
    {
        [self editButtonTouched:nil];
    }
    else
    {
        self.eventDictionary = [[self.event cachingDictionary] mutableCopy];
    }
    
    [self initTags];
    [self updateUIForEvent];
    
    self.isInEditMode = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self initBottomButtonsContainer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
}

- (BOOL)shouldAnimateViewController:(UIViewController *)vc
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateEventDataType
{
    if(self.isNewEvent && !self.event.type)
    {
        self.eventDataType = EventDataTypeValueMeasure;
    }
    else
    {
        self.eventDataType = [_event eventDataType];
    }
}

- (void)initBottomButtonsContainer
{
    __block EventDetailsViewController *weakSelf = self;
    self.bottomButtonsContainer = [[[UINib nibWithNibName:@"DetailsBottomButtonsContainer" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self.bottomButtonsContainer setShareButtonTouchHandler:^(UIButton *shareButton) {
        [weakSelf shareEvent];
    }];
    [self.bottomButtonsContainer setDeleteButtonTouchHandler:^(UIButton *deleteButton) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert.Message.DeleteConfirmation", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"NO", nil) otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(alertView.cancelButtonIndex != buttonIndex)
            {
                [weakSelf deleteEvent];
            }
        }];
    }];
    CGRect frame = self.bottomButtonsContainer.frame;
    frame.origin.y = self.tableView.frame.size.height - 64 - self.bottomButtonsContainer.frame.size.height;
    if(![UIDevice isiOS7Device])
    {
        frame.origin.y+=20;
    }
    self.bottomButtonsContainer.frame = frame;
    [self.view addSubview:self.bottomButtonsContainer];
    [self.view bringSubviewToFront:self.bottomButtonsContainer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.bottomButtonsContainer.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.bottomButtonsContainer.frame.size.height;
    self.bottomButtonsContainer.frame = frame;
    [self.view bringSubviewToFront:self.bottomButtonsContainer];
}

#pragma mark - UI update

- (void)updateUIForEvent
{
    if(self.eventDataType == EventDataTypeImage)
    {
        [self updateUIForEventImageType];
    }
    else if(self.eventDataType == EventDataTypeValueMeasure)
    {
        [self updateUIForValueEventType];
    }
    else if(self.eventDataType == EventDataTypeNote)
    {
        [self updateUIForNoteEventType];
    }
    
    NSDate *date = nil;
    if (self.eventDictionary[@"time"] == nil) {
        date = [NSDate date];
    } else {
        date =  [[NotesAppController sharedInstance].connection localDateFromServerTime:[self.eventDictionary[@"time"] doubleValue]];
    }
    
   
    self.timeLabel.text = [[NotesAppController sharedInstance].dateFormatter stringFromDate:date];
    self.streamsLabel.text = [self.event breadcrumbsForStream:self.eventDictionary[@"streamId"] inStreamsList:self.streams];
    if([self.streamsLabel.text length] < 1)
    {
        self.streamsLabel.text = NSLocalizedString(@"ViewController.Streams.SelectStream", nil);
    }
    [self updateTagsLabel];
    [self.tableView reloadData];
}

- (void)updateUIForEventImageType
{
    
    [self.event firstAttachmentAsImage:^(UIImage *image) {
        self.imageView.image = image;
    } errorHandler:nil];
    self.descriptionLabel.text = self.eventDictionary[@"description"];
}

- (void)updateUIForValueEventType
{
    if(self.isNewEvent)
    {
        self.valueLabel.text = @"";
        self.valueTypeLabel.text = @"";
        return;
    }
    NSString *type = self.eventDictionary[@"type"];
    PYEventType *eventType = [[PYEventTypes sharedInstance] pyTypeForString:type];
    NSString *unit = [eventType symbol];
    if (! unit) { unit = eventType.formatKey ; }
    
    
    NSString *value = [NSString stringWithFormat:@"%@ %@",[self.eventDictionary[@"content"] description], unit];
    [self.valueLabel setText:value];
    
    NSString *formatDescription = [eventType localizedName];
    if (! formatDescription) { unit = eventType.key ; }
    [self.valueTypeLabel setText:formatDescription];
    self.descriptionLabel.text = self.eventDictionary[@"description"];
}

- (void)updateUIForNoteEventType
{
    self.descriptionLabel.text = self.eventDictionary[@"content"];
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForCellAtIndexPath:indexPath withEvent:self.event];
}

#pragma mark - UITableViewDeleagate methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self heightForCellAtIndexPath:indexPath withEvent:self.event];
    cell.alpha = height > 0 ? 1.0f : 0.0f;
}

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

- (void)cancelButtonTouched:(id)sender
{
    if(self.isNewEvent)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        self.eventDictionary = [[self.event cachingDictionary] mutableCopy];
        [self updateUIForEvent];
        self.shouldUpdateEvent = NO;
        [self editButtonTouched:nil];
    }
}

- (IBAction)editButtonTouched:(id)sender
{
    if(self.isInEditMode)
    {
        if(!self.eventDictionary[@"streamId"] && sender)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ViewController.Streams.SelectStream", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        [self switchFromEditingMode];
    }
    else
    {
        [self switchToEditingMode];
    }
    self.isInEditMode = !self.isInEditMode;
    [self.cells enumerateObjectsUsingBlock:^(BaseDetailCell *cell, NSUInteger idx, BOOL *stop) {
        [cell setIsInEditMode:self.isInEditMode];
    }];
}

- (void)switchFromEditingMode
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setHidesBackButton:NO];
    if(self.streamPickerVC)
    {
        [self closeStreamPicker];
    }
    
    if(self.shouldCreateEvent)
    {
        [self saveEvent];
    } else if(self.shouldUpdateEvent)
    {
        [self updateEvent];
    }
    self.editButton.title = @"Edit";
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tagsLabel.alpha = 1.0f;
        self.tokenContainer.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)switchToEditingMode
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Cancel"
                                   style: UIBarButtonItemStyleBordered
                                   target:self action: @selector(cancelButtonTouched:)];
    
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setHidesBackButton:YES];
    
    self.editButton.title = @"Done";
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tagsLabel.alpha = 0.0f;
        self.tokenContainer.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
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
        if(self.eventDataType == EventDataTypeNote)
        {
            if (self.eventDictionary[@"content"] && [text isEqualToString:self.eventDictionary[@"content"]]) return;
            self.eventDictionary[@"content"] = text;
        }
        else
        {
            if (self.eventDictionary[@"description"] && [text isEqualToString:self.eventDictionary[@"description"]]) return;
            self.eventDictionary[@"description"] = text;
        }
        self.shouldUpdateEvent = YES;
        [self updateUIForEvent];
    };
    if(self.eventDataType == EventDataTypeNote)
    {
        textEditorVC.text = self.eventDictionary[@"content"] ? self.eventDictionary[@"content"] : @"";
    }
    else
    {
        textEditorVC.text = self.eventDictionary[@"description"] ? self.eventDictionary[@"description"] : @"";
    }
}

- (void)setupDatePickerViewController:(DatePickerViewController *)dpVC
{
    NSDate *date = [[NotesAppController sharedInstance].connection localDateFromServerTime:[self.eventDictionary[@"time"] doubleValue]];
    dpVC.selectedDate = date;
    [dpVC setDateDidChangeBlock:^(NSDate *newDate, DatePickerViewController *dp) {
        if([newDate timeIntervalSince1970] == [date timeIntervalSince1970]) return;
        self.eventDictionary[@"time"] = [NSNumber numberWithDouble:[newDate timeIntervalSince1970]];
        self.shouldUpdateEvent = YES;
        [self updateUIForEvent];
    }];
}

- (void)setupImagePreviewViewController:(ImagePreviewViewController*)imagePreviewVC
{
    [self.event firstAttachmentAsImage:^(UIImage *image) {
        imagePreviewVC.image = image;
    } errorHandler:nil];
    
    imagePreviewVC.descText = self.event.eventDescription;
}

- (void)setupAddNumericalValueViewController:(AddNumericalValueViewController*)addNumericalValueVC
{
    NSString *type = self.eventDictionary[@"type"];
    if(type)
    {
        NSArray *components = [type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            addNumericalValueVC.value = [self.eventDictionary[@"content"] description];
            addNumericalValueVC.valueClass = [components objectAtIndex:0];
            addNumericalValueVC.valueType = [components objectAtIndex:1];
        }
    }
    [addNumericalValueVC setValueDidChangeBlock:^(NSString* valueClass, NSString *valueType, NSString* value, AddNumericalValueViewController *addNumericalVC) {
        self.eventDictionary[@"content"] = value;
        self.eventDictionary[@"type"] = [NSString stringWithFormat:@"%@/%@",valueClass,valueType];
        self.shouldUpdateEvent = YES;
        [self updateUIForEvent];
    }];
}

- (void)setupStreamPickerViewController:(StreamPickerViewController*)streamPickerVC
{
    streamPickerVC.streamId = self.eventDictionary[@"streamId"];
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
    if(stream == nil || stream.streamId == nil)
    {
        NSLog(@"SSSSSSS");
    }
    if(stream.streamId)
    {
        self.eventDictionary[@"streamId"] = stream.streamId;
    }
    else
    {
        [self.eventDictionary removeObjectForKey:@"streamId"];
    }
    self.shouldUpdateEvent = YES;
}

- (void)closeStreamPicker
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
    if(indexPath.row == 0)
    {
        if(self.eventDataType == EventDataTypeValueMeasure)
        {
            return kValueCellHeight;
        }
        return 0;
    }
    if(indexPath.row == 1)
    {
        if(self.eventDataType == EventDataTypeImage)
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
        height = fmaxf(height, 54);
        self.descriptionLabelConstraint1.constant = fmaxf(height - 10,0);
        self.descriptionLabelConstraint2.constant = fmaxf(height - 10,0);
        self.descriptionLabelConstraint3.constant = fmaxf(height - 20,0);
        return height;
    }
    return 54;
}

- (BOOL) shouldCreateEvent
{
    return (self.event.eventId == nil);
}

- (void)saveEvent
{
    self.event = [PYEvent eventFromDictionary:self.eventDictionary onConnection:[NotesAppController sharedInstance].connection];
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
    self.event = [PYEvent eventFromDictionary:self.eventDictionary onConnection:[NotesAppController sharedInstance].connection];
    [self showLoadingOverlay];
    [NotesAppController sharedConnectionWithID:nil
                   noConnectionCompletionBlock:nil
                           withCompletionBlock:^(PYConnection *connection)
     {
         [connection updateEvent:self.event successHandler:^(NSString *stoppedId)
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

- (void)shareEvent
{
    NSLog(@"SHARE EVENT");
}

#pragma mark - Tags

- (IBAction)tokenDoneButtonTouched:(id)sender
{
    [self.tokenField.textField resignFirstResponder];
    [self.tokenField updateTokensInTextField:self.tokenField.textField];
    NSMutableArray *tokens = [NSMutableArray array];
    for(JSTokenButton *token in self.tokenField.tokens)
    {
        [tokens addObject:[token representedObject]];
    }
    self.eventDictionary[@"tags"] = tokens;
    [self updateTagsLabel];
    self.shouldUpdateEvent = YES;
}

#pragma mark - JSTOkenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    [self updateTagsLabel];
    return NO;
}

- (void)tokenFieldWillBeginEditing:(JSTokenField *)tokenField
{
    
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField
{
    
}

- (void)initTags
{
    self.tokenField.delegate = self;
    self.tagDoneButtonConstraint.constant = 0;
    [self.view layoutIfNeeded];
    for(NSString *tag in self.eventDictionary[@"tags"])
    {
        [self.tokenField addTokenWithTitle:tag representedObject:tag];
    }
    [self updateTagsLabel];
}

- (void)updateTagsLabel
{
    if([self.eventDictionary[@"tags"] count] == 0)
    {
        self.tagsLabel.text = NSLocalizedString(@"ViewController.Tags.TapToAdd", nil);
    }
    else
    {
        self.tagsLabel.text = [self.eventDictionary[@"tags"] componentsJoinedByString:@", "];
    }
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShown:(NSNotification *)notification
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:DetailCellTypeTags inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.tagDoneButtonConstraint.constant = 68;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSInteger rowToSelect = 0;
    if(self.eventDataType == EventDataTypeImage)
    {
        rowToSelect = DetailCellTypeImage;
    }
    else if(self.eventDataType == EventDataTypeNote)
    {
        rowToSelect = DetailCellTypeDescription;
    }
    else
    {
        rowToSelect = DetailCellTypeValue;
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowToSelect inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.tagDoneButtonConstraint.constant = 0;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
