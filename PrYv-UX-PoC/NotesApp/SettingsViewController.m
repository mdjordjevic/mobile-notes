//
//  SettingsViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/17/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "SettingsViewController.h"
#import <PryvApiKit/PryvApiKit.h>
#import "DataService.h"

@interface SettingsViewController ()

@property (nonatomic, strong) IBOutlet UILabel *logoutLabel;

- (void)popVC:(id)sender;

@end

@implementation SettingsViewController

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
	self.navigationItem.leftItemsSupplementBackButton = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_add_active"] target:self action:@selector(popVC:)];
    
    PYConnection *connection = [[NotesAppController sharedInstance] connection];
    if(connection)
    {
        self.logoutLabel.text = [NSString stringWithFormat:@"Logout (%@)",connection.userID];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row == 0)
    {
        [[NotesAppController sharedInstance] setConnection:nil];
    }
}

- (void)popVC:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
