//
//  ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ViewController.h"
#import "BrowseEventsViewController.h"
#import "DataService.h"

@interface ViewController ()

@property (nonatomic, strong) BrowseEventsViewController *browseEventsVC;

- (void)userDidLogoutNotification:(NSNotification*)notification;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogoutNotification:)
                                                 name:kUserDidLogoutNotification
                                               object:nil];
    
    self.browseEventsVC = [UIStoryboard instantiateViewControllerWithIdentifier:@"BrowseEventsViewController_ID"];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:self.browseEventsVC];
    navVC.navigationBar.translucent = NO;
    [self.navigationController presentViewController:navVC animated:NO completion:nil];
    [self initSignIn];
}

#pragma mark - Sign In

- (void)initSignIn
{
    if(![[NotesAppController sharedInstance] connection])
    {
        
        NSArray *keys = [NSArray arrayWithObjects:  kPYAPIConnectionRequestStreamId,
                         kPYAPIConnectionRequestLevel,
                         nil];
        
        NSArray *objects = [NSArray arrayWithObjects:   kPYAPIConnectionRequestAllStreams,
                            kPYAPIConnectionRequestManageLevel,
                            nil];
        
        NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects
                                                                                    forKeys:keys]];
        
        [PYWebLoginViewController requestConnectionWithAppId:@"pryv-ios-app"
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

- (void)pyWebLoginSuccess:(PYConnection *)pyConnection
{
    [pyConnection synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
    self.browseEventsVC.enabled = YES;
    [[NotesAppController sharedInstance] setConnection:pyConnection];
}

- (void)pyWebLoginAborded:(NSString*)reason
{
    self.browseEventsVC.enabled = NO;
    [self.browseEventsVC hideLoadingOverlay];
    NSLog(@"Login aborted with reason: %@",reason);
}

- (void)pyWebLoginError:(NSError *)error
{
    NSLog(@"Login error: %@",error);
}

#pragma mark - Notifications

- (void)userDidLogoutNotification:(NSNotification *)notification
{
    self.browseEventsVC.enabled = NO;
    [self.browseEventsVC clearCurrentData];
    [self.browseEventsVC dismissViewControllerAnimated:YES completion:^{
        [[DataService sharedInstance] invalidateStreamListCache];
        [self initSignIn];
    }];
    
}


@end
