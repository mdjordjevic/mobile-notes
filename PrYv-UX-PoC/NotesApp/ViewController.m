//
//  ViewController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 4/24/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - Sign In

- (void)initSignIn
{
    NSArray *permissions = @[@{@"channelId": @"*", @"level": @"manage"}];
    
    [PYClient setDefaultDomainStaging];
    [PYWebLoginViewController requesAccessWithAppId:@"pryv-sdk-ios-example"
                                     andPermissions:permissions
                                           delegate:self];
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



@end
