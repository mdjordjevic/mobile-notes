//
//  MeasurementSettingsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/27/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "MeasurementSettingsViewController.h"
#import "MeasurementController.h"
#import "MeasurementSet.h"
#import <QuartzCore/QuartzCore.h>

@interface MeasurementSettingsViewController ()

@property (nonatomic, strong) NSArray *measurementSets;

- (void)popVC:(id)sender;

@end

@implementation MeasurementSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.measurementSets = [[MeasurementController sharedInstance] availableMeasurementSets];
    
    self.navigationController.navigationBar.layer.masksToBounds = NO;
    self.navigationItem.leftItemsSupplementBackButton = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_back"] target:self action:@selector(popVC:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_measurementSets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MeasurementSetCell_ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    MeasurementSet *set = [_measurementSets objectAtIndex:indexPath.row];
  
    [cell.textLabel setText:[set localizedName]];
    [cell.detailTextLabel setText:[set localizedDescription]];
    
    if([[[MeasurementController sharedInstance] userSelectedMeasurementSets] containsObject:set.key])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeasurementSet *set = [_measurementSets objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone)
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[MeasurementController sharedInstance] addMeasurementSetWithKey:set.key];
    }
    else
    {
        if([[[MeasurementController sharedInstance] userSelectedMeasurementSets] count] > 1)
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [[MeasurementController sharedInstance] removeMeasurementSetWithKey:set.key];
        }
    }
}

- (void)popVC:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
