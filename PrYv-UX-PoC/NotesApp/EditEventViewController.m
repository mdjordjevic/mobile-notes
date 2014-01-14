//
//  EditEventViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "EditEventViewController.h"
#import "CategoryCell.h"
#import "DataService.h"
#import "JSTokenField.h"
#import "JSTokenButton.h"
#import "UserHistoryEntry.h"
#import "PYStream+Helper.h"
#import "PhotoPreviewElement.h"
#import "CellStyleModel.h"
#import "TextNotePreviewElement.h"
#import "MeasurementPreviewElement.h"
#import "UIAlertView+PrYv.h"

#define SELECTED_LIST ([self.stream.children count] == 0 ? self.rootStreams : self.streams)
#define IS_EDIT_MODE (self.event != nil)
#define kDefaultPhotoCommentText @"Enter your comment"

@interface EditEventViewController () <JSTokenFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *eventPreviewContainer;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *selectedLocationLabel;
@property (nonatomic, strong) IBOutlet UIImageView *eventPreviewImageView;
@property (nonatomic, strong) IBOutlet UILabel *eventPreviewTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventPreviewSubtitleLabel;
@property (nonatomic, strong) IBOutlet UITextView *commentTextView;
@property (nonatomic, strong) IBOutlet JSTokenField *tagsField;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *listBackButton;
@property (nonatomic, strong) NSArray *streams;
@property (nonatomic, strong) NSArray *rootStreams;
@property (nonatomic, strong) PYStream *stream;

- (IBAction)backButtonTouched:(id)sender;
- (void)doneButtonTouched:(id)sender;
- (void)doneTagsFieldAction:(id)sender;
- (void)textFieldDone:(id)sender;
- (void)updateUIElements;
- (NSArray*)parentStreamList;

@end

@implementation EditEventViewController

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
    
    [self addCustomBackButton];
    
    self.doneButton = [UIBarButtonItem flatBarItemWithImage:[[UIImage imageNamed:@"navbar_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)] text:@"Post" target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    UIToolbar *tipToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    tipToolbar.barStyle = UIBarStyleBlackTranslucent;
    tipToolbar.items = [NSArray arrayWithObjects:
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                      target:nil
                                                                      action:nil],
                        [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                         style:UIBarButtonItemStyleDone
                                                        target:self
                                                        action:@selector(doneTagsFieldAction:)],
                        nil];
    [tipToolbar sizeToFit];
    self.tagsField.textField.inputAccessoryView = tipToolbar;
    
    if(self.entry)
    {
        for(NSString *tag in self.entry.tags)
        {
            [self.tagsField addTokenWithTitle:tag representedObject:tag];
        }
    }
    
    if(IS_EDIT_MODE)
    {
        for(NSString *tag in self.event.tags)
        {
            [self.tagsField addTokenWithTitle:tag representedObject:tag];
        }
        
        CellStyleType eventType = [[DataService sharedInstance] cellStyleForEvent:self.event];
        if(eventType == CellStyleTypePhoto)
        {
            self.eventElement = [[PhotoPreviewElement alloc] init];
            PYAttachment *att = [self.event.attachments objectAtIndex:0];
            UIImage *img = [UIImage imageWithData:att.fileData];
            self.eventElement.previewImage = img;
        }
        if([self.event.eventDescription length] > 0)
        {
            self.commentTextView.text = self.event.eventDescription;
        }
    }

    if([self.eventElement isKindOfClass:[PhotoPreviewElement class]])
    {
        self.eventPreviewImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    self.commentTextView.hidden = NO;
    UIToolbar *tipToolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    tipToolbar2.barStyle = UIBarStyleBlackTranslucent;
    tipToolbar2.items = [NSArray arrayWithObjects:
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                      target:nil
                                                                      action:nil],
                        [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                         style:UIBarButtonItemStyleDone
                                                        target:self
                                                        action:@selector(textFieldDone:)],
                        nil];
    [tipToolbar2 sizeToFit];
    self.commentTextView.inputAccessoryView = tipToolbar2;
    
    self.tagsField.delegate = self;
    
    [self showLoadingOverlay];
    [[DataService sharedInstance] fetchAllStreamsWithCompletionBlock:^(id object, NSError *error) {
        if(error)
        {
            NSLog(@"ERROR!!!!!!!");
        }
        else
        {
            self.streams = object;
            if((self.entry && self.entry.streamId) || IS_EDIT_MODE)
            {
                NSString *streamID = IS_EDIT_MODE ? self.event.streamId : self.entry.streamId;
                for(PYStream *stream in self.streams)
                {
                    if([stream.streamId isEqualToString:streamID])
                    {
                        self.stream = stream;
                        break;
                    }
                }
            }
            self.rootStreams = [self.streams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parentId = nil"]];
        }
        [self updateUIElements];
        [self.tableView reloadData];
        [self hideLoadingOverlay];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIElements
{
    NSString *selectedText = [self.stream breadcrumbsInStreamList:self.streams];
    if(!selectedText && [selectedText length] < 1)
    {
        selectedText = @"Select stream";
    }
    self.selectedLocationLabel.text = selectedText;
    
    self.eventPreviewImageView.image = [self.eventElement elementPreviewImage];
    self.eventPreviewTitleLabel.text = [self.eventElement elementTitle];
    NSString *subtitle = [self.eventElement elementSubtitle];
    if(!subtitle)
    {
        self.eventPreviewSubtitleLabel.hidden = YES;
        self.eventPreviewTitleLabel.center = CGPointMake(self.eventPreviewTitleLabel.center.x, self.eventPreviewImageView.center.y);
    }
    self.listBackButton.hidden = (self.stream == nil);
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self parentStreamList] count] + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CategoryCell_ID";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(indexPath.row == [[self parentStreamList] count])
    {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.titleLabel.text = @"Add new Stream";
    }
    else
    {
        PYStream *stream = [[self parentStreamList] objectAtIndex:indexPath.row];
        if([stream.children count] > 0)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.titleLabel.text = stream.name;
        BOOL isSelected = [stream.streamId isEqualToString:self.stream.streamId];
        [cell setSelected:isSelected animated:NO];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [[self parentStreamList] count])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Stream name:" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView showWithCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(alertView.cancelButtonIndex != buttonIndex)
            {
                NSString *streamName = [[alertView textFieldAtIndex:0] text];
                if([streamName length] > 0)
                {
                    [self showLoadingOverlay];
                    PYStream *stream = [[PYStream alloc] init];
                    stream.name = streamName;
                    stream.parentId = self.stream.streamId;
                    // TODO Explain why a stream is created ?
                    [[DataService sharedInstance] createStream:stream
                                           withCompletionBlock:^(id object, NSError *error) {
                        if(error)
                        {
                            [self hideLoadingOverlay];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                        else
                        {
                            [[DataService sharedInstance] invalidateStreamListCache];
                            [[DataService sharedInstance] fetchAllStreamsWithCompletionBlock:^(id object, NSError *error) {
                                self.streams = object;
                                self.rootStreams = [self.streams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"parentId = nil"]];
                                for(PYStream *st in self.streams)
                                {
                                    if([st.name isEqualToString:stream.name] && ([st.parentId isEqualToString:stream.parentId] || stream.parentId == nil))
                                    {
                                        self.stream = st;
                                        break;
                                    }
                                }
                                [self.tableView reloadData];
                                [self updateUIElements];
                                [self hideLoadingOverlay];
                            }];
                        }
                    }];
                }
            }
        }];
    }
    else
    {
        PYStream *stream = [[self parentStreamList] objectAtIndex:indexPath.row];
        self.stream = stream;
        [self.tableView reloadData];
        [self updateUIElements];
    }
    
}

#pragma mark - Actions

- (void)backButtonTouched:(id)sender
{
    self.stream = [self.stream parentStreamInList:self.streams];
    [self.tableView reloadData];
    [self updateUIElements];
}

- (void)textFieldDone:(id)sender
{
    [self.commentTextView resignFirstResponder];
}

- (void)doneButtonTouched:(id)sender
{
    if(!self.stream)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You should select a stream first" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self.tagsField textFieldDidEndEditing:self.tagsField.textField];
    [self tokenFieldShouldReturn:self.tagsField];
    PYEvent *event = nil;
    if(IS_EDIT_MODE)
    {
        event = self.event;
    }
    else
    {
        event = [[PYEvent alloc] init];
    }
    event.streamId = self.stream.streamId;
    event.tags = _tags;
    if(![self.commentTextView.text isEqualToString:kDefaultPhotoCommentText])
    {
        event.eventDescription = self.commentTextView.text;
    }
    if(IS_EDIT_MODE)
    {
        if([self.event.attachments count] == 0)
        {
            event.eventContent = _eventElement.textValue ? _eventElement.textValue : _eventElement.value;
            event.type = [_eventElement.klass stringByAppendingFormat:@"/%@",_eventElement.format];
        }
        else
        {
            [self.event.attachments removeAllObjects];
        }
        if(![self.commentTextView.text isEqualToString:kDefaultPhotoCommentText])
        {
            event.eventDescription = self.commentTextView.text;
        }
        [self showLoadingOverlay];
        [[DataService sharedInstance] updateEvent:event withCompletionBlock:^(id object, NSError *error) {
            [self hideLoadingOverlay];
            if(error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
            }
        }];
    }
    else
    {
        PYAttachment *attachment = [_eventElement attachment];
        if(attachment)
        {
            [event addAttachment:attachment];
            event.type = @"picture/attached";
        }
        else
        {
            event.eventContent = _eventElement.textValue ? _eventElement.textValue : _eventElement.value;
            event.type = [_eventElement.klass stringByAppendingFormat:@"/%@",_eventElement.format];
            
        }
//        [self showLoadingOverlay];
        [[DataService sharedInstance] saveEvent:event withCompletionBlock:^(id object, NSError *error) {
//            [self hideLoadingOverlay];
//            if(error)
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//            }
//            else
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
//            }
        }];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - JSTokenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField updateTokensInTextField:tokenField.textField];
    return NO;
}

- (void)doneTagsFieldAction:(id)sender
{
    [self.tagsField.textField resignFirstResponder];
    [self.tagsField updateTokensInTextField:self.tagsField.textField];
    NSMutableArray *tokens = [NSMutableArray array];
    for(JSTokenButton *token in self.tagsField.tokens)
    {
        [tokens addObject:[token representedObject]];
    }
    self.tags = tokens;
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([self.commentTextView.text isEqualToString:kDefaultPhotoCommentText])
    {
        self.commentTextView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([self.commentTextView.text length] == 0)
    {
        self.commentTextView.text = kDefaultPhotoCommentText;
    }
}

#pragma mark - Utils

- (NSArray*)parentStreamList
{
    if(!self.stream)
    {
        return self.rootStreams;
    }
    else
    {
        return self.stream.children;
    }
}

@end
