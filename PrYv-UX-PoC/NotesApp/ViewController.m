//
//  ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

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

#pragma mark - Sign In

- (void)initSignIn
{
    if(![[NotesAppController sharedInstance] access])
    {
        NSArray *permissions = @[@{@"channelId": @"*", @"level": @"manage"}];
        [PYWebLoginViewController requesAccessWithAppId:@"pryv-sdk-ios-example"
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
    return self;
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
