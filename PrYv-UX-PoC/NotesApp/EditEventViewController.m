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

@interface EditEventViewController ()

@property (nonatomic, strong) IBOutlet UIView *eventPreviewContainer;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *selectedLocationLabel;

@property (nonatomic, strong) NSArray *channels;

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
	
    CGRect previewFrame = CGRectMake(10, 10, 300, 100);
    UIView *previewView = [_eventElement elementPreviewViewForFrame:previewFrame];
    [self.eventPreviewContainer addSubview:previewView];
    
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

#pragma mark - UITableViewDataSource and UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_channels count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CategoryCell_ID";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Channel *channel = [_channels objectAtIndex:indexPath.row];
    cell.titleLabel.text = channel.channelName;
    return cell;
}

@end
