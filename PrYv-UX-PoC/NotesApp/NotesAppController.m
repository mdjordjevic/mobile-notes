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
- (void)loadSavedConnection;
- (void)saveConnection:(PYConnection*)connection;
- (void)removeConnection:(PYConnection*)connection;

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
    [self loadSavedConnection];
}

- (void)loadSavedConnection
{
    NSString *lastUsedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUsedUsernameKey];
    if(lastUsedUsername)
    {
        NSString *accessToken = [SSKeychain passwordForService:kServiceName account:lastUsedUsername];
        self.connection = [[PYConnection alloc] initWithUsername:lastUsedUsername andAccessToken:accessToken];
    }
}

- (void)setConnection:(PYConnection *)connection
{
    if(connection != _connection)
    {
        [self removeConnection:_connection];
        _connection = connection;
        [self saveConnection:connection];
    }
    if(_connection)
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

- (void)saveConnection:(PYConnection *)connection
{
    [[NSUserDefaults standardUserDefaults] setObject:connection.userID forKey:kLastUsedUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SSKeychain setPassword:connection.accessToken forService:kServiceName account:connection.userID];
}

- (void)removeConnection:(PYConnection *)connection
{
    [SSKeychain deletePasswordForService:kServiceName account:connection.userID];
}

- (BOOL)isOnline
{
    return _connection.online;
}

@end
