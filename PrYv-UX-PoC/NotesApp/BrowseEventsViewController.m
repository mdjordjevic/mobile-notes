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
#import "Stream.h"
#import "CellStyleModel.h"
#import "CustomSegmentedControl.h"
#import "AddNumericalValueViewController.h"
#import "SettingsViewController.h"
#import "TextNoteViewController.h"
#import "PhotoNoteViewController.h"
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "PYEvent+Helper.h"
#import "UIImage+PrYv.h"
#import "DetailsViewController.h"
#import "PYStream+Helper.h"
#import "MNMPullToRefreshManager.h"
#import "BrowseCell.h"
#import "NoteCell.h"
#import "ValueCell.h"
#import "PictureCell.h"

#define IS_LRU_SECTION self.isMenuOpen
#define IS_BROWSE_SECTION !self.isMenuOpen

@interface BrowseEventsViewController () <UIActionSheetDelegate,MNMPullToRefreshManagerClient>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *streams;
@property (nonatomic, strong) NSArray *shortcuts;
@property (nonatomic, strong) MNMPullToRefreshManager *pullToRefreshManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)settingButtonTouched:(id)sender;
- (void)loadData;
- (void)didReceiveEventAddedNotification:(NSNotification*)notification;
- (void)userDidReceiveAccessTokenNotification:(NSNotification*)notification;

@end

@implementation BrowseEventsViewController

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
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_settings"] target:self action:@selector(settingButtonTouched:)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveEventAddedNotification:)
                                                 name:kEventAddedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidReceiveAccessTokenNotification:)
                                                 name:kAppDidReceiveAccessTokenNotification
                                               object:nil];
    self.pullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60 tableView:self.tableView withClient:self];
    
    self.tableView.alpha = 0.0f;
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    __block BrowseEventsViewController *weakSelf = self;
    [[LRUManager sharedInstance] fetchLRUEntriesWithCompletionBlock:^{
        weakSelf.shortcuts = [[LRUManager sharedInstance] lruEntries];
        if(IS_LRU_SECTION)
        {
            [self.tableView reloadData];
        }
    }];
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

- (void)loadData
{
    static BOOL isLoading;
    if(!isLoading)
    {
        isLoading = YES;
        [self showLoadingOverlay];
        [[DataService sharedInstance] fetchAllStreamsWithCompletionBlock:^(id streamsObject, NSError *error) {
            if(streamsObject)
            {
                self.streams = streamsObject;
                [[DataService sharedInstance] fetchAllEventsWithCompletionBlock:^(id eventsObject, NSError *error) {
                    if(eventsObject)
                    {
                        self.events = eventsObject;
                        [self.tableView reloadData];
                        [UIView animateWithDuration:0.2 animations:^{
                            self.tableView.alpha = 1.0f;
                        }];
                        [self hideLoadingOverlay];
                        [self.pullToRefreshManager tableViewReloadFinishedAnimated:YES];
                    }
                    
                }];
            }
            isLoading = NO;
        }];
        
    }
}

- (NSDateFormatter*)dateFormatter
{
    if(!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
//        [_dateFormatter setDateFormat:@"MM/dd/yyyy hh:mma"];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _dateFormatter;
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
        CellStyleType cellType = [[DataService sharedInstance] dataTypeForEvent:event];
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.menuTableView])
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    if(IS_BROWSE_SECTION)
    {
        PYEvent *event = [_events objectAtIndex:indexPath.row];
        CellStyleType cellStyleType = [[DataService sharedInstance] dataTypeForEvent:event];
        BrowseCell *cell = nil;
        if(cellStyleType == CellStyleTypePhoto)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"PictureCell_ID"];
            [cell prepareForReuse];
            if([event.attachments count] > 0)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    PYAttachment *att = [event.attachments objectAtIndex:0];
                    UIImage *img = [UIImage imageWithData:att.fileData];
                    CGSize newSize = img.size;
                    CGFloat maxSide = MAX(newSize.width, newSize.height);
                    CGFloat ratio = maxSide / [(PictureCell*)cell pictureView].bounds.size.width;
                    newSize = CGSizeMake(floorf(newSize.width/ratio), floorf(newSize.height/ratio));
                    img = [img imageScaledToSize:newSize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
                            [[(PictureCell*)cell pictureView] setAlpha:0.0f];
                        } completion:^(BOOL finished) {
                            [[(PictureCell*)cell pictureView] setImage:img];
                            [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
                                [[(PictureCell*)cell pictureView] setAlpha:1.0f];
                            } completion:^(BOOL finished) {
                                
                            }];
                        }];
                        
                    });
                });
            }
        }
        else if(cellStyleType == CellStyleTypeText)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell_ID"];
            [[(NoteCell*)cell noteLabel] setText:[event.eventContent description]];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ValueCell_ID"];
            NSArray *components = [event.type componentsSeparatedByString:@"/"];
            
            
            if([components count] > 1)
            {
                NSString *value = [NSString stringWithFormat:@"%@ %@",[event.eventContent description],[components objectAtIndex:1]];
                [[(ValueCell*)cell valueLabel] setText:value];
            }
        }
        cell.commentLabel.text = event.eventDescription;
        cell.streamLabel.text = [event eventBreadcrumbsForStreamsList:self.streams];
        [cell updateTags:event.tags];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:event.time];
        cell.dateLabel.text = [self.dateFormatter stringFromDate:date];
        
        return cell;
    }
    static NSString *CellIdentifier = @"BrowseEventsCell_ID";
    BrowseEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UserHistoryEntry *entry = [_shortcuts objectAtIndex:indexPath.row];
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
        if(entry.dataType == CellStyleTypeText)
        {
            TextNoteViewController *textVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"TextNoteViewController_ID"];
            textVC.entry = entry;
            [self.navigationController pushViewController:textVC animated:YES];
        }
        else if(entry.dataType == CellStyleTypePhoto)
        {
            PhotoNoteViewController *photoVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"PhotoNoteViewController_ID"];
            photoVC.entry = entry;
            [self.navigationController pushViewController:photoVC animated:YES];
        }
        else
        {
            AddNumericalValueViewController *addNVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"AddNumericalValueViewController_ID"];
            addNVC.entry = entry;
            [self.navigationController pushViewController:addNVC animated:YES];
        }
    }
    else
    {
        PYEvent *event = [_events objectAtIndex:indexPath.row];
        DetailsViewController *detailsVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"DetailsViewController_ID"];
        detailsVC.event = event;
        [self.navigationController pushViewController:detailsVC animated:YES];
    }
}

- (void)topMenuDidSelectOptionAtIndex:(NSInteger)index
{
    __block BrowseEventsViewController *weakSelf = self;
    [self setMenuVisible:NO animated:YES withCompletionBlock:^{
        switch (index) {
            case 0:
            {
                TextNoteViewController *textVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"TextNoteViewController_ID"];
                [weakSelf.navigationController pushViewController:textVC animated:YES];
            }
                break;
            case 1:
            {
                AddNumericalValueViewController *addNVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"AddNumericalValueViewController_ID"];
                [weakSelf.navigationController pushViewController:addNVC animated:YES];
            }
                break;
            case 2:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose photo shource" delegate:weakSelf cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Library", nil];
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
    [self presentModalViewController:navVC animated:YES];
}

- (void)clearCurrentData
{
    self.events = nil;
    [self.tableView reloadData];
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

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
    {
        return;
    }
    UIImagePickerControllerSourceType sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    PhotoNoteViewController *photoVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"PhotoNoteViewController_ID"];
    photoVC.sourceType = sourceType;
    [self.navigationController pushViewController:photoVC animated:YES];
}

#pragma mark - MNMPullToRefreshManagerClient methods

- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
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
