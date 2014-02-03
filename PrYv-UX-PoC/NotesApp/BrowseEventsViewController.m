//
//  BrowseEventsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseEventsViewController.h"
#import "BrowseEventsCell.h"
#import "DataService.h"
#import "CellStyleModel.h"
#import "AddNumericalValueViewController.h"
#import "PhotoNoteViewController.h"
#import "SettingsViewController.h"
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "PYEvent+Helper.h"
#import "UIImage+PrYv.h"
#import "PYStream+Helper.h"
#import "MNMPullToRefreshManager.h"
#import "BrowseCell.h"
#import "NoteCell.h"
#import "ValueCell.h"
#import "PictureCell.h"
#import "UnkownCell.h"
#import "NSString+Utils.h"
#import "AppConstants.h"
#import "EventDetailsViewController.h"

#define IS_LRU_SECTION self.isMenuOpen
#define IS_BROWSE_SECTION !self.isMenuOpen

static NSString *browseCellIdentifier = @"BrowseEventsCell_ID";

@interface BrowseEventsViewController () <UIActionSheetDelegate,MNMPullToRefreshManagerClient>


@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *streams;
@property (nonatomic, strong) NSArray *shortcuts;
@property (nonatomic, strong) MNMPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, strong) PYEvent *eventToShowOnAppear;

@property (nonatomic, strong) PYEventFilter *filter;

- (void)settingButtonTouched:(id)sender;
- (void)loadData;
- (void)didReceiveEventAddedNotification:(NSNotification*)notification;
- (void)userDidReceiveAccessTokenNotification:(NSNotification*)notification;
- (void)filterEventUpdate:(NSNotification*)notification;
- (int)addEventToList:(PYEvent*)eventToAdd;

@end

@implementation BrowseEventsViewController

BOOL displayNonStandardEvents;

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
    
    [self loadSettings];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BrowseEventCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:browseCellIdentifier];
    
    self.navigationItem.title = @"Pryv";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_pryv"] target:self action:@selector(settingButtonTouched:)];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveEventAddedNotification:)
                                                 name:kEventAddedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidReceiveAccessTokenNotification:)
                                                 name:kAppDidReceiveAccessTokenNotification
                                               object:nil];
    // Monitor changes of option "show non standard events"
    [[NSUserDefaults standardUserDefaults] addObserver:self
                    forKeyPath:kPYAppSettingUIDisplayNonStandardEvents
                       options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    self.pullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60 tableView:self.tableView withClient:self];
    
    
    self.events = [[NSMutableArray alloc] init];
    
    self.filter = [[PYEventFilter alloc] initWithConnection:[[NotesAppController sharedInstance] connection]
                                                   fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                     toTime:PYEventFilter_UNDEFINED_TOTIME
                                                      limit:100
                                             onlyStreamsIDs:nil
                                                       tags:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterEventUpdate:) name:@"EVENTS" object:self.filter];
    
    
    self.tableView.alpha = 0.0f;
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Pryv";
    __block BrowseEventsViewController *weakSelf = self;
    [[LRUManager sharedInstance] fetchLRUEntriesWithCompletionBlock:^{
        weakSelf.shortcuts = [[LRUManager sharedInstance] lruEntries];
        if(IS_LRU_SECTION)
        {
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.eventToShowOnAppear)
    {
        PYEvent *event = self.eventToShowOnAppear;
        self.eventToShowOnAppear = nil;
        [self showEventDetailsForEvent:event withEventIsNewFlag:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSettings
{
  displayNonStandardEvents = [[NSUserDefaults standardUserDefaults] boolForKey:kPYAppSettingUIDisplayNonStandardEvents];
}

- (void)loadData
{
    NSLog(@"*261");
    static BOOL isLoading;
    if(!isLoading)
    {
        isLoading = YES;
        [self showLoadingOverlay];
        [[DataService sharedInstance] fetchAllStreamsWithCompletionBlock:^(id streamsObject, NSError *error) {
            if(streamsObject)
            {
                self.streams = streamsObject;
                [UIView animateWithDuration:0.2 animations:^{
                    self.tableView.alpha = 1.0f;
                }];
                [self hideLoadingOverlay];
                [self.pullToRefreshManager tableViewReloadFinishedAnimated:YES];
            }
            isLoading = NO;
        }];
        
    }
    
    [self.filter update];
}



#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    if(IS_BROWSE_SECTION)
    {
        return [self.events count];
    }
    if(IS_LRU_SECTION)
    {
        return [self.shortcuts count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    if(IS_BROWSE_SECTION)
    {
        PYEvent *event = [_events objectAtIndex:indexPath.row];
        CellStyleType cellType = [event cellStyle];
        if(cellType == CellStyleTypePhoto)
        {
            return 180;
        }
        return 160;
    }
    if(IS_LRU_SECTION)
    {
        return 72;
    }
    return 0;
}

- (BrowseCell *)cellInTableView:(UITableView *)tableView forCellStyleType:(CellStyleType)cellStyleType
{
    BrowseCell *cell;
    if(cellStyleType == CellStyleTypePhoto)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PictureCell_ID"];
    }
    else if(cellStyleType == CellStyleTypeText)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell_ID"];
    }
    else if (cellStyleType == CellStyleTypeMeasure || cellStyleType == CellStyleTypeMoney)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ValueCell_ID"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UnkownCell_ID"];
    }
    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    NSInteger row = indexPath.row;
    if(IS_BROWSE_SECTION)
    {
        PYEvent *event = [_events objectAtIndex:row];
        CellStyleType cellStyleType = [event cellStyle];
        BrowseCell *cell = [self cellInTableView:tableView forCellStyleType:cellStyleType];
        [cell updateWithEvent:event andListOfStreams:self.streams];
        [cell prepareForReuse];
        return cell;
    }
    BrowseEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:browseCellIdentifier];
    UserHistoryEntry *entry = [_shortcuts objectAtIndex:row];
    cell.channelFolderLabel.text = [PYStream breadcrumsForStreamId:entry.streamId inStreamList:self.streams];
    CellStyleType cellStyleType = entry.dataType;
    CellStyleSize cellSize = CellStyleSizeSmall;
    CellStyleModel *cellModel = [[CellStyleModel alloc] initWithCellStyleSize:cellSize andCellStyleType:cellStyleType];
    [cell updateWithCellStyleModel:cellModel];
    [cell updateTags:entry.tags];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    if(IS_LRU_SECTION)
    {
        UserHistoryEntry *entry = [_shortcuts objectAtIndex:indexPath.row];
        [self showEventDetailsWithUserHistoryEntry:entry];
    }
    else
    {
        PYEvent *event = [_events objectAtIndex:indexPath.row];
        [self showEventDetailsForEvent:event withEventIsNewFlag:NO];
    }
}

- (void)topMenuDidSelectOptionAtIndex:(NSInteger)index
{
    __block BrowseEventsViewController *weakSelf = self;
    [self setMenuVisible:NO animated:YES withCompletionBlock:^{
        switch (index) {
            case 0:
            {
                PYEvent *event = [[PYEvent alloc] init];
                event.type = @"note/txt";
                [weakSelf showEventDetailsForEvent:event withEventIsNewFlag:YES];
            }
                break;
            case 1:
            {
                PYEvent *event = [[PYEvent alloc] init];
                [weakSelf showEventDetailsForEvent:event withEventIsNewFlag:YES];
            }
                break;
            case 2:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Alert.Message.PhotoSource", nil) delegate:weakSelf cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Camera", nil),NSLocalizedString(@"Library", nil), nil];
                [actionSheet showInView:weakSelf.view];
            }
                break;
            default:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This option is not yet implemented" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
                break;
        }
    }];
}

#pragma mark - Show details

- (void)showEventDetailsForEvent:(PYEvent*)event withEventIsNewFlag:(BOOL)eventIsNew
{
    [self showEventDetailsForEvent:event withEventIsNewFlag:eventIsNew andUserHistoryEntry:nil];
}

- (void)showEventDetailsWithUserHistoryEntry:(UserHistoryEntry*)entry
{
    [self showEventDetailsForEvent:nil withEventIsNewFlag:YES andUserHistoryEntry:entry];
}

- (void)showEventDetailsForEvent:(PYEvent*)event
              withEventIsNewFlag:(BOOL)eventIsNew
             andUserHistoryEntry:(UserHistoryEntry*)entry
{
    EventDetailsViewController *eventDetailVC = (EventDetailsViewController*)[[UIStoryboard detailsStoryBoard] instantiateViewControllerWithIdentifier:@"EventDetailsViewController_ID"];
    eventDetailVC.event = event;
    if(entry && !event)
    {
        eventDetailVC.event = [entry reconstructEvent];
    }
    if(eventIsNew)
    {
        eventDetailVC.event.time = [[NSDate new] timeIntervalSince1970];
    }
    eventDetailVC.streams = self.streams;
    eventDetailVC.isNewEvent = eventIsNew;
    eventDetailVC.entry = entry;
    self.title = NSLocalizedString(@"Back", nil);
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

#pragma mark - Top menu visibility changed

- (void)topMenuVisibilityWillChange
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)topMenuVisibilityDidChange
{
    [self.tableView reloadData];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Actions

- (void)settingButtonTouched:(id)sender
{
    SettingsViewController *settingsVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController_ID"];
    settingsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    navVC.navigationBar.translucent = NO;
    [self presentViewController:navVC animated:YES completion:nil];
}


#pragma mark - Event List manipulations


- (BOOL)clientFilterMatchEvent:(PYEvent*)event
{
    return displayNonStandardEvents || ! ([event cellStyle] == CellStyleTypeUnkown );
}

/**
 * add an event to the list, will match it against current client filter
 * return index of event Added, -1 if not added
 */
- (int)addEventToList:(PYEvent*) eventToAdd {
    if (! [self clientFilterMatchEvent:eventToAdd]) return -1;
    PYEvent* kEvent = nil;
    if (self.events.count > 0) {
        for (int k = 0; k < self.events.count; k++) {
            kEvent = [self.events objectAtIndex:k];
            if (kEvent.time < eventToAdd.time) {
                [self.events insertObject:eventToAdd atIndex:k];
                return k;
            }
        }
    }
    [self.events addObject:eventToAdd];
    return self.events.count;
}


- (void)clearCurrentData
{
    [self.events removeAllObjects];
    
    NSArray* currentEvents = [self.filter currentEventsSet];
    for (int i = 0; i < currentEvents.count; i++) {
        [self addEventToList:[currentEvents objectAtIndex:i]];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (keyPath == kPYAppSettingUIDisplayNonStandardEvents) {
        [self loadSettings];
        [self clearCurrentData];
    }
    
}

#pragma mark - Notifications

- (void)didReceiveEventAddedNotification:(NSNotification*)notification
{
    [self.navigationController popToViewController:self animated:YES];
    [self loadData];
}

- (void)userDidReceiveAccessTokenNotification:(NSNotification *)notification
{
    [self loadData];
}

- (void)filterEventUpdate:(NSNotification *)notification
{
    
    NSDictionary *message = (NSDictionary*) notification.userInfo;
    
    
    
    NSArray* toAdd = [message objectForKey:@"ADD"];
    NSArray* toRemove = [message objectForKey:@"REMOVE"];
    NSArray* modify = [message objectForKey:@"MODIFY"];
    
    // [_tableView beginUpdates];
    // ref : http://www.nsprogrammer.com/2013/07/updating-uitableview-with-dynamic-data.html
    // ref2 : http://stackoverflow.com/questions/4777683/how-do-i-efficiently-update-a-uitableview-with-animation
    
    // events are sent ordered by time
    if (toRemove) {
        NSLog(@"*262 REMOVE %i", toRemove.count);
        
        PYEvent* kEvent = nil;
        PYEvent* eventToRemove = nil;
        for (int i = toRemove.count -1 ; i >= 0; i--) {
            eventToRemove = [toRemove objectAtIndex:i];
            for (int k =  self.events.count; k >= 0 ; k--) {
                kEvent = [self.events objectAtIndex:k];
                if ([eventToRemove.eventId isEqualToString:kEvent.eventId]) {
                    [self.events removeObjectAtIndex:k];
                    break; // assuming an event is only represented once in the list
                }
            }
        }
        
    }
    
    if (modify) {
        NSLog(@"*262 MODIFY %i", modify.count);
    }
    
    // events are sent ordered by time
    if (toAdd && toAdd.count > 0) {
        
        NSLog(@"*262 ADD %i", toAdd.count);
        
        for (int i = toAdd.count - 1 ; i >= 0; i--) {
            [self addEventToList:[toAdd objectAtIndex:i]];
        }
        
    }
    // [_tableView endUpdates];
    NSLog(@"*262 END");
    [self.tableView reloadData]; // until update is implmeneted
    [self hideLoadingOverlay];
    
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    UIImagePickerControllerSourceType sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    PhotoNoteViewController *photoVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"PhotoNoteViewController_ID"];
    photoVC.sourceType = sourceType;
    photoVC.browseVC = self;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (void)setPickedImage:(UIImage *)pickedImage
{
    if(_pickedImage != pickedImage)
    {
        _pickedImage = pickedImage;
        [self showImageDetails];
    }
}

- (void)showImageDetails
{
    PYEvent *event = [[PYEvent alloc] init];
    event.type = @"picture/attached";
    NSData *imageData = UIImageJPEGRepresentation(self.pickedImage, 0.5);
    if(imageData)
    {
        NSString *imgName = [NSString randomStringWithLength:10];
        PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:imgName fileName:[NSString stringWithFormat:@"%@.jpeg",imgName]];
        [event.attachments addObject:att];
        self.eventToShowOnAppear = event;
    }
}

#pragma mark - MNMPullToRefreshManagerClient methods

- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    self.filter.limit++;
    [self loadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullToRefreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullToRefreshManager tableViewReleased];
}

@end
