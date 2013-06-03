//
//  NotesAppController.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/13/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "NotesAppController.h"
#import <PryvApiKit/PryvApiKit.h>
#import "DataService.h"
#import "SSKeychain.h"

#define kServiceName @"com.pryv.notesapp"
#define kLastUsedUsernameKey @"lastUsedUsernameKey"

NSString *const kAppDidReceiveAccessTokenNotification = @"kAppDidReceiveAccessTokenNotification";
NSString *const kUserDidLogoutNotification = @"kUserDidLogoutNotification";

@interface NotesAppController ()

- (void)initObject;
- (void)userDidLogout;
- (void)loadSavedAccess;
- (void)saveAccess:(PYAccess*)access;
- (void)removeAccess:(PYAccess*)access;

@end

@implementation NotesAppController

+ (NotesAppController*)sharedInstance
{
    static NotesAppController *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[NotesAppController alloc] init];
        [_sharedInstance initObject];
    });
    return _sharedInstance;
}

- (void)initObject
{
    [PYClient setDefaultDomainStaging];
    [self loadSavedAccess];
}

- (void)loadSavedAccess
{
    NSString *lastUsedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedUsernameKey];
    if(lastUsedUsername)
    {
        NSString *accessToken = [SSKeychain passwordForService:kServiceName account:lastUsedUsername];
        self.access = [[PYAccess alloc] initWithUsername:lastUsedUsername andAccessToken:accessToken];
    }
}

- (void)setAccess:(PYAccess *)access
{
    if(access != _access)
    {
        [self removeAccess:_access];
        _access = access;
        [self saveAccess:access];
    }
    if(_access)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveAccessTokenNotification object:nil];
    }
    else
    {
        [self userDidLogout];
    }
}

- (void)userDidLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
}

- (void)saveAccess:(PYAccess *)access
{
    [[NSUserDefaults standardUserDefaults] setObject:access.userID forKey:kLastUsedUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SSKeychain setPassword:access.accessToken forService:kServiceName account:access.userID];
}

- (void)removeAccess:(PYAccess *)access
{
    [SSKeychain deletePasswordForService:kServiceName account:access.userID];
}

@end
