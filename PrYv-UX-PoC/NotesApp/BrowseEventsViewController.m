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
#import "Channel.h"
#import "CellStyleModel.h"
#import "CustomSegmentedControl.h"
#import "AddNumericalValueViewController.h"
#import "SettingsViewController.h"
#import "TextNoteViewController.h"
#import "LRUManager.h"
#import "UserHistoryEntry.h"

#define IS_LRU_SECTION (self.segmentedControl.selectedIndex == 0)
#define IS_BROWSE_SECTION (self.segmentedControl.selectedIndex == 1)

@interface BrowseEventsViewController () <CustomSegmentedControlDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSArray *shortcuts;
@property (nonatomic, strong) IBOutlet CustomSegmentedControl *segmentedControl;

- (CellStyleType)cellStyleTypeFromEvent:(PYEvent*)event;
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
    self.segmentedControl.delegate = self;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_settings"] target:self action:@selector(settingButtonTouched:)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveEventAddedNotification:)
                                                 name:kEventAddedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidReceiveAccessTokenNotification:)
                                                 name:kAppDidReceiveAccessTokenNotification
                                               object:nil];
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
        [[DataService sharedInstance] fetchAllEventsWithCompletionBlock:^(id object, NSError *error) {
            if(object)
            {
                self.events = [NSMutableArray array];
                for(Channel *channel in object)
                {
                    [self.events addObjectsFromArray:channel.events];
                }
                [self.tableView reloadData];
                [self hideLoadingOverlay];
            }
            isLoading = NO;
        }];
    }
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
        return 104;
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
    static NSString *CellIdentifier = @"BrowseEventsCell_ID";
    BrowseEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(IS_BROWSE_SECTION)
    {
        PYEvent *event = [_events objectAtIndex:indexPath.row];
        if(event.folderId)
        {
            cell.channelFolderLabel.text = [NSString stringWithFormat:@"%@/%@",event.channelId,event.folderId];
        }
        else
        {
            cell.channelFolderLabel.text = event.channelId;
        }
        cell.valueLabel.text = [event.value description];
        CellStyleType cellStyleType = [self cellStyleTypeFromEvent:event];
        CellStyleSize cellSize = CellStyleSizeBig;
        CellStyleModel *cellModel = [[CellStyleModel alloc] initWithCellStyleSize:cellSize andCellStyleType:cellStyleType];
        [cell updateWithCellStyleModel:cellModel];
        [cell updateTags:event.tags];
    }
    else
    {
        UserHistoryEntry *entry = [_shortcuts objectAtIndex:indexPath.row];
        if(entry.folder)
        {
            cell.channelFolderLabel.text = [NSString stringWithFormat:@"%@/%@",entry.channel.name,entry.folder.name];
        }
        else
        {
            cell.channelFolderLabel.text = entry.channel.name;
        }
        CellStyleType cellStyleType = entry.dataType;
        CellStyleSize cellSize = CellStyleSizeSmall;
        CellStyleModel *cellModel = [[CellStyleModel alloc] initWithCellStyleSize:cellSize andCellStyleType:cellStyleType];
        [cell updateWithCellStyleModel:cellModel];
        [cell updateTags:entry.tags];
    }
    
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
        else
        {
            AddNumericalValueViewController *addNVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"AddNumericalValueViewController_ID"];
            addNVC.entry = entry;
            [self.navigationController pushViewController:addNVC animated:YES];
        }
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
                
            default:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This option is not yet implemented" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
                break;
        }
    }];
}

- (CellStyleType)cellStyleTypeFromEvent:(PYEvent *)event
{
    NSLog(@"eventClass: %@",event.eventClass);
    NSLog(@"eventFormat: %@",event.eventFormat);
    if([event.eventClass isEqualToString:@"note"])
    {
        return CellStyleTypeText;
    }
    if([event.eventClass isEqualToString:@"mass"])
    {
        return CellStyleTypeMass;
    }
    if([event.eventClass isEqualToString:@"money"])
    {
        return CellStyleTypeMoney;
    }
    if([event.eventClass isEqualToString:@"length"])
    {
        return CellStyleTypeLength;
    }
    
    return CellStyleTypeLength;
}

#pragma mark - CustomSegmentedControlDelegate methods

- (void)customSegmentedControl:(CustomSegmentedControl *)segmentedControl didSelectIndex:(NSInteger)index
{
    __block BrowseEventsViewController *weakSelf = self;
    [[LRUManager sharedInstance] fetchLRUEntriesWithCompletionBlock:^{
        weakSelf.shortcuts = [[LRUManager sharedInstance] lruEntries];
    }];
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)settingButtonTouched:(id)sender
{
    SettingsViewController *settingsVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController_ID"];
    settingsVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self presentModalViewController:navVC animated:YES];
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

@end
