//
//  NotesAppController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/13/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SettingsController;

typedef NS_ENUM(NSInteger, EventDataType)
{
    EventDataTypeNote,
    EventDataTypeValueMeasure,
    EventDataTypeImage
};

#define kLocalizedKey NSLocalizedString(@"MeasurementSetLocalizedKey", nil)

extern NSString *const kAppDidReceiveAccessTokenNotification;
extern NSString *const kUserDidLogoutNotification;

@class PYConnection;

@interface NotesAppController : NSObject

@property (nonatomic, strong) PYConnection *connection;
@property (nonatomic, readonly) BOOL isOnline;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) SettingsController* settingController;

+ (NotesAppController*)sharedInstance;


@end
