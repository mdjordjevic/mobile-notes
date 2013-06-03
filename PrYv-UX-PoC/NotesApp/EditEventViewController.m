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

#define IS_CHANNEL_LIST (self.listType == EditEventListTypeChannel)
#define IS_FOLDER_LIST (self.listType == EditEventListTypeFolder)

typedef NS_ENUM(NSInteger, EditEventListType)
{
    EditEventListTypeChannel,
    EditEventListTypeFolder
};

@interface EditEventViewController ()

@property (nonatomic, strong) IBOutlet UIView *eventPreviewContainer;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *selectedLocationLabel;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic) EditEventListType listType;
@property (nonatomic, strong) UIBarButtonItem *saveButton;

@property (nonatomic, strong) NSArray *channels;

- (IBAction)backButtonTouched:(id)sender;
- (void)saveButtonTouched:(id)sender;
- (void)updateUIElements;

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
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(saveButtonTouched:)];
    
    [self.navigationItem setRightBarButtonItem:_saveButton];

	self.eventPreviewContainer.frame = CGRectMake(0, 0, 320, 184);
    CGRect previewFrame = self.eventPreviewContainer.bounds;
    UIView *previewView = [_eventElement elementPreviewViewForFrame:previewFrame];
    [[_eventElement tagsLabel] setDelegate:self];
    [self.eventPreviewContainer addSubview:previewView];
    self.title = [_eventElement elementTitle];
    
    self.listType = EditEventListTypeChannel;
    [self updateUIElements];
    
    [self showLoadingOverlay];
    [DataService fetchAllChannelsWithCompletionBlock:^(id object, NSError *error) {
        self.channels = object;
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
    NSString *selectedText = nil;
    NSString *descriptionText = nil;
    BOOL saveButtonIsEnabled = NO;
    if(_folder)
    {
        selectedText = [NSString stringWithFormat:@"%@/%@",_channel.channelName,_folder.folderName];
        descriptionText = [NSString stringWithFormat:@"%@, %@",_channel.channelName,_folder.folderName];
        saveButtonIsEnabled = YES;
    }
    else if(_channel)
    {
        selectedText = [_channel channelName];
        descriptionText = [_channel channelName];
        saveButtonIsEnabled = YES;
    }
    else
    {
        selectedText = @"Select channel";
        descriptionText = @"";
    }
    self.selectedLocationLabel.text = selectedText;
    self.backButton.hidden = IS_CHANNEL_LIST;
    [self.eventElement updateDescriptionWithText:descriptionText];
    _saveButton.enabled = saveButtonIsEnabled;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return IS_CHANNEL_LIST ? [_channels count] : [_channel.folders count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CategoryCell_ID";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(IS_CHANNEL_LIST)
    {
        Channel *channel = [_channels objectAtIndex:indexPath.row];
        if([channel.folders count] > 0)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.titleLabel.text = channel.channelName;
        BOOL isSelected = [channel.channelId isEqualToString:_channel.channelId];
        [cell setSelected:isSelected animated:NO];
    }
    else
    {
        Folder *folder = [_channel.folders objectAtIndex:indexPath.row];
        cell.titleLabel.text = folder.folderName;
        cell.accessoryType = UITableViewCellAccessoryNone;
        BOOL isSelected = [folder.folderId isEqualToString:_folder.folderId];
        [cell setSelected:isSelected animated:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_CHANNEL_LIST)
    {
        self.channel = [_channels objectAtIndex:indexPath.row];
        if([_channel.folders count] > 0)
        {
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
            self.listType = EditEventListTypeFolder;
            [self.tableView reloadData];
        }
        [self updateUIElements];
    }
    else
    {
        self.folder = [_channel.folders objectAtIndex:indexPath.row];
        [self updateUIElements];
    }
}

#pragma mark - Actions

- (void)backButtonTouched:(id)sender
{
    if(IS_FOLDER_LIST)
    {
        self.folder = nil;
        self.listType = EditEventListTypeChannel;
        [self updateUIElements];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
        [self.tableView reloadData];
    }
}

- (void)saveButtonTouched:(id)sender
{
    PYEvent *event = [[PYEvent alloc] init];
    event.folderId = _folder.folderId;
    event.channelId = _channel.channelId;
    event.tags = _tags;
    event.value = _eventElement.value;
    event.eventClass = _eventElement.klass;
    event.eventFormat = _eventElement.format;
    
    [_channel.pyChannel createEvent:event requestType:PYRequestTypeAsync successHandler:^(NSString *newEventId, NSString *stoppedId) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Event is saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } errorHandler:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.tags = [textField.text componentsSeparatedByString:@","];
    [textField resignFirstResponder];
    return NO;
}

@end
