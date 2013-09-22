//
//  NotesAppController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/13/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLocalizedKey NSLocalizedString(@"MeasurementSetLocalizedKey", nil)

extern NSString *const kAppDidReceiveAccessTokenNotification;
extern NSString *const kUserDidLogoutNotification;

@class PYConnection;

@interface NotesAppController : NSObject

@property (nonatomic, strong) PYConnection *connection;

+ (NotesAppController*)sharedInstance;

@end
