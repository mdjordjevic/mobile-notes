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

#import "AppConstants.h"



@interface SettingsViewController ()


@property (nonatomic, strong) IBOutlet UILabel *versionTitle;
@property (nonatomic, strong) IBOutlet UILabel *versionLabel;


@property (nonatomic, strong) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UISwitch *uiDisplayNonStandardEventsSwitch;
- (IBAction)uiDisplayNonStandardEventsSwitchValueChanged:(id)sender;


@property (nonatomic, strong) IBOutlet UILabel *sendMailLabel;

- (void)popVC:(id)sender;

- (void)loadSettings;
- (void)loadInformations;

- (void)displayFeedBackMailView ;

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

- (void)loadSettings
{
   BOOL uiDisplayNonStandardEventsSwitchValue =
    [[NSUserDefaults standardUserDefaults] boolForKey:kPYAppSettingUIDisplayNonStandardEvents];
    
   [self.uiDisplayNonStandardEventsSwitch setOn:uiDisplayNonStandardEventsSwitchValue];
}

- (void)loadInformations
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"%@ build %@",
                             version, build];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.leftItemsSupplementBackButton = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem flatBarItemWithImage:[UIImage imageNamed:@"icon_add_active"] target:self action:@selector(popVC:)];
    
    
    self.sendMailLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayFeedBackMailView)];
    [self.sendMailLabel addGestureRecognizer:tapGR];

    
    
    PYConnection *connection = [[NotesAppController sharedInstance] connection];
    if(connection)
    {
        self.logoutLabel.text = [NSString stringWithFormat:@"Logout (%@)",connection.userID];
    }
    [self loadSettings];
    [self loadInformations];
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


- (IBAction)uiDisplayNonStandardEventsSwitchValueChanged:(id)sender {
  [[NSUserDefaults standardUserDefaults]
     setBool:[self.uiDisplayNonStandardEventsSwitch isOn]
     forKey:kPYAppSettingUIDisplayNonStandardEvents];
}

- (void)popVC:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - feedback MFMailComposeViewControllerDelegate


- (void)displayFeedBackMailView {

    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Feedback from Pryv app"];
    
    [picker setToRecipients:[NSArray arrayWithObjects:@"support@pryv.com", nil]];
    
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];

    NSString *username = @"";
    PYConnection *connection = [[NotesAppController sharedInstance] connection];
    if(connection)
    {
        username = connection.userID;
    }

    
    // Fill out the email body text.
    NSString *emailBody = [NSString stringWithFormat:
                           @"\n\n\n\n\n\n\n---------------------------------------\ntechnical info, please leave as-is\nversion:%@ build %@\nusername: %@",
                           version, build, username];
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Present the mail composition interface.
    [self presentViewController:picker animated:YES completion:nil];
    //[picker release]; // Can safely release the controller now.
}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
