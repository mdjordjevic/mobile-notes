//
//  DataService.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PYEvent, PYStream;

typedef void (^DataServiceCompletionBlock)(id object, NSError *error);

extern NSString *const kSavingEventActionFinishedNotification;

@interface DataService : NSObject

+ (DataService*)sharedInstance;
- (void)fetchAllStreamsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)fetchAllEventsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock;

- (NSInteger)cellStyleForEvent:(PYEvent*)event;
- (EventDataType)eventDataTypeForEvent:(PYEvent*)event;
- (void)invalidateStreamListCache;

@end
