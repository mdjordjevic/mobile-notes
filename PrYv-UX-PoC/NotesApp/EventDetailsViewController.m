//
//  EventDetailsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "EventDetailsViewController.h"

@interface EventDetailsViewController ()

@property (nonatomic) BOOL isStreamExpanded;
@property (nonatomic) BOOL isTagExpanded;
@property (nonatomic, strong) NSArray *defaultHeights;
@property (nonatomic, strong) NSArray *streamSelectorOpenHeights;
@property (nonatomic, strong) NSArray *tagEditorOpenHeights;

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
    self.defaultHeights = @[@(88),@(44),@(88),@(44),@(44)];
    self.streamSelectorOpenHeights = @[@(88),@(0),@(0),@(0),@(352)];
    self.tagEditorOpenHeights = @[@(88),@(0),@(0),@(44),@(0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isTagExpanded)
    {
        return [self.tagEditorOpenHeights[indexPath.row] floatValue];
    }
    else if(self.isStreamExpanded)
    {
        return [self.streamSelectorOpenHeights[indexPath.row] floatValue];
    }
    return [self.defaultHeights[indexPath.row] floatValue];
}

#pragma mark - UITableViewDeleagate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 3)
    {
        self.isStreamExpanded = NO;
        self.isTagExpanded = !self.isTagExpanded;
    }
    else if(indexPath.row == 4)
    {
        self.isTagExpanded = NO;
        self.isStreamExpanded = !self.isStreamExpanded;
    }
    else
    {
        self.isTagExpanded = NO;
        self.isStreamExpanded = NO;
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
