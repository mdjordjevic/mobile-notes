//
//  ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ViewController.h"
#import "BrowseEventsViewController.h"

@interface ViewController ()

@property (nonatomic, strong) BrowseEventsViewController *browseEventsVC;

- (void)userDidLogoutNotification:(NSNotification*)notification;

@end

@implementation ViewController

- (id)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidLogoutNotification:)
                                                     name:kUserDidLogoutNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.browseEventsVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"BrowseEventsViewController_ID"];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:self.browseEventsVC];
    [self.navigationController presentViewController:navVC animated:NO completion:nil];
    [self initSignIn];
}

#pragma mark - Sign In

- (void)initSignIn
{
    if(![[NotesAppController sharedInstance] access])
    {
        NSArray *objects = [NSArray arrayWithObjects:@"*", @"manage", nil];
        NSArray *keys = [NSArray arrayWithObjects:@"channelId", @"level", nil];
        
        NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        [PYWebLoginViewController requestAccessWithAppId:@"pryv-sdk-ios-example"
                                          andPermissions:permissions
                                                delegate:self];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveAccessTokenNotification object:nil];
    }
}

#pragma mark - PYWebLoginDelegate

- (UIViewController*)pyWebLoginGetController
{
    return self.browseEventsVC;
}

- (void)pyWebLoginSuccess:(PYAccess*)pyAccess
{
    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
    [[NotesAppController sharedInstance] setAccess:pyAccess];
}

- (void)pyWebLoginAborded:(NSString*)reason
{
    NSLog(@"Login aborted with reason: %@",reason);
}

- (void)pyWebLoginError:(NSError *)error
{
    NSLog(@"Login error: %@",error);
}

#pragma mark - Notifications

- (void)userDidLogoutNotification:(NSNotification *)notification
{
    [self initSignIn];
}


@end
