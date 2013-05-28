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

NSString *const kAppDidReceiveAccessTokenNotification = @"kAppDidReceiveAccessTokenNotification";
NSString *const kUserDidLogoutNotification = @"kUserDidLogoutNotification";

@interface NotesAppController ()

- (void)initObject;
- (void)userDidLogout;

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
    
}

- (void)setAccess:(PYAccess *)access
{
    if(access != _access)
    {
        _access = access;
        if(access)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppDidReceiveAccessTokenNotification object:nil];
        }
        else
        {
            [self userDidLogout];
        }
        
    }
    else
    {
        [self userDidLogout];
    }
}

- (void)userDidLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
    NSLog(@"USER DID LOGOUT");
}

@end
