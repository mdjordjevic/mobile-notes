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

#define IS_CHANNEL_LIST (self.listType == EditEventListTypeChannel)
#define IS_FOLDER_LIST (self.listType == EditEventListTypeFolder)

typedef NS_ENUM(NSInteger, EditEventListType)
{
    EditEventListTypeChannel,
    EditEventListTypeFolder
};

@interface EditEventViewController () <JSTokenFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView *eventPreviewContainer;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *selectedLocationLabel;
@property (nonatomic, strong) IBOutlet UIImageView *eventPreviewImageView;
@property (nonatomic, strong) IBOutlet UILabel *eventPreviewTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventPreviewSubtitleLabel;
@property (nonatomic, strong) IBOutlet UIButton *listBackButton;
@property (nonatomic, strong) IBOutlet JSTokenField *tagsField;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic) EditEventListType listType;

@property (nonatomic, strong) NSArray *channels;

- (IBAction)backButtonTouched:(id)sender;
- (void)doneButtonTouched:(id)sender;
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
    
    [self addCustomBackButton];
    
    self.doneButton = [UIBarButtonItem flatBarItemWithImage:[[UIImage imageNamed:@"navbar_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 4, 14, 4)] text:@"Done" target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    if(self.entry)
    {
//        self.channel = [[Channel alloc] initWithPYChannel:self.entry.channel];
//        self.folder = [[Folder alloc] initWithPYFolder:self.entry.folder];
        self.listType = EditEventListTypeFolder;
        for(NSString *tag in self.entry.tags)
        {
            [self.tagsField addTokenWithTitle:tag representedObject:tag];
        }
    }
    else
    {
        self.listType = EditEventListTypeChannel;
    }
    
    [self updateUIElements];
    
    self.tagsField.delegate = self;
    
    [self showLoadingOverlay];
//    [[DataService sharedInstance] fetchAllChannelsWithCompletionBlock:^(id object, NSError *error) {
//        self.channels = object;
//        [self.tableView reloadData];
//        [self hideLoadingOverlay];
//    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIElements
{
//    NSString *selectedText = nil;
//    NSString *descriptionText = nil;
//    BOOL saveButtonIsEnabled = NO;
//    if(_folder && _folder.folderName)
//    {
//        selectedText = [NSString stringWithFormat:@"%@/%@",_channel.channelName,_folder.folderName];
//        descriptionText = [NSString stringWithFormat:@"%@, %@",_channel.channelName,_folder.folderName];
//        saveButtonIsEnabled = YES;
//    }
//    else if(_channel)
//    {
//        selectedText = [_channel channelName];
//        descriptionText = [_channel channelName];
//        saveButtonIsEnabled = YES;
//    }
//    else
//    {
//        selectedText = @"Select channel";
//        descriptionText = @"";
//    }
//    self.selectedLocationLabel.text = selectedText;
//    
//    self.eventPreviewImageView.image = [self.eventElement elementPreviewImage];
//    self.eventPreviewTitleLabel.text = [self.eventElement elementTitle];
//    NSString *subtitle = [self.eventElement elementSubtitle];
//    if(!subtitle)
//    {
//        self.eventPreviewSubtitleLabel.hidden = YES;
//        self.eventPreviewTitleLabel.center = CGPointMake(self.eventPreviewTitleLabel.center.x, self.eventPreviewImageView.center.y);
//    }
//    self.listBackButton.hidden = IS_CHANNEL_LIST;
//    self.doneButton.enabled = saveButtonIsEnabled;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return IS_CHANNEL_LIST ? [_channels count] : [_channel.folders count];
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = @"CategoryCell_ID";
//    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if(IS_CHANNEL_LIST)
//    {
//        Channel *channel = [_channels objectAtIndex:indexPath.row];
//        if([channel.folders count] > 0)
//        {
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
//        else
//        {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
//        cell.titleLabel.text = channel.channelName;
//        BOOL isSelected = [channel.channelId isEqualToString:_channel.channelId];
//        [cell setSelected:isSelected animated:NO];
//    }
//    else
//    {
//        Folder *folder = [_channel.folders objectAtIndex:indexPath.row];
//        cell.titleLabel.text = folder.folderName;
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        BOOL isSelected = [folder.folderId isEqualToString:_folder.folderId];
//        [cell setSelected:isSelected animated:NO];
//    }
//    
//    return cell;
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(IS_CHANNEL_LIST)
//    {
//        self.channel = [_channels objectAtIndex:indexPath.row];
//        if([_channel.folders count] > 0)
//        {
//            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
//            self.listType = EditEventListTypeFolder;
//            [self.tableView reloadData];
//        }
//        [self updateUIElements];
//    }
//    else
//    {
//        self.folder = [_channel.folders objectAtIndex:indexPath.row];
//        [self updateUIElements];
//    }
}

#pragma mark - Actions

- (void)backButtonTouched:(id)sender
{
//    if(IS_FOLDER_LIST)
//    {
//        self.folder = nil;
//        self.listType = EditEventListTypeChannel;
//        [self updateUIElements];
//        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
//        [self.tableView reloadData];
//    }
}

- (void)doneButtonTouched:(id)sender
{
//    [self.tagsField textFieldDidEndEditing:self.tagsField.textField];
//    [self tokenFieldShouldReturn:self.tagsField];
//    PYEvent *event = [[PYEvent alloc] init];
//    event.folderId = _folder.folderId;
//    event.channelId = _channel.channelId;
//    event.tags = _tags;
//    event.value = _eventElement.textValue ? _eventElement.textValue : _eventElement.value;
//    event.eventClass = _eventElement.klass;
//    event.eventFormat = _eventElement.format;
//    [self showLoadingOverlay];
//    [[DataService sharedInstance] saveEvent:event inChannel:_channel.pyChannel withCompletionBlock:^(id object, NSError *error) {
//        [self hideLoadingOverlay];
//        if(error)
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//        }
//        else
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kEventAddedNotification object:nil];
//        }
//    }];
}

#pragma mark - JSTokenFieldDelegate methods

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    [tokenField.textField resignFirstResponder];
    NSMutableArray *tokens = [NSMutableArray array];
    for(JSTokenButton *token in tokenField.tokens)
    {
        [tokens addObject:[token representedObject]];
    }
    self.tags = tokens;
    return YES;
}

@end
