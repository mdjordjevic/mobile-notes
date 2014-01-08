//
//  DataService.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataService.h"
#import <PryvApiKit/PYClient.h>
#import <PryvApiKit/PYEventTypes.h>
#import <PryvApiKit/PYMeasurementSet.h>
#import <PryvApiKit/PYStream.h>
#import <PryvApiKit/PYEvent.h>
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"

#define kStreamListCacheTimeout 60 * 60 //60 minutes

NSString *const kSavingEventActionFinishedNotification = @"kSavingEventActionFinishedNotification";

@interface DataService ()

@property (nonatomic, strong) NSArray *cachedStreams;
@property (nonatomic, strong) NSDate *lastStreamsUpdateTimestamp;

- (void)initObject;
- (void)executeCompletionBlockOnMainQueue:(DataServiceCompletionBlock)completionBlock withObject:(id)object andError:(NSError*)error;
- (void)saveEventAsShortcut:(PYEvent*)event;
- (void)populateArray:(NSMutableArray*)array withStrems:(NSArray*)streams;

@end

@implementation DataService

+ (DataService*)sharedInstance
{
    static DataService *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DataService alloc] init];
        [_sharedInstance initObject];
    });
    return _sharedInstance;
}

- (void)initObject
{
    
}


- (void)fetchAllStreamsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYConnection *connection = [[NotesAppController sharedInstance] connection];
        if(!connection)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,[NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil]);
            });
        }
        else
        {
            if(self.cachedStreams && fabs([self.lastStreamsUpdateTimestamp timeIntervalSinceNow]) < kStreamListCacheTimeout)
            {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:self.cachedStreams andError:nil];
            }
            else
            {
                [connection getAllStreamsWithRequestType:PYRequestTypeSync gotCachedStreams:^(NSArray *cachedStreamsList) {
                    //if(![[NotesAppController sharedInstance] isOnline])
                    //{
                    NSMutableArray *streams = [NSMutableArray array];
                    [self populateArray:streams withStrems:cachedStreamsList];
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:streams andError:nil];
                    //}
                    
                } gotOnlineStreams:^(NSArray *onlineStreamList) {
                    //if([[NotesAppController sharedInstance] isOnline])
                    //{
                    NSMutableArray *streams = [NSMutableArray array];
                    [self populateArray:streams withStrems:onlineStreamList];
                    self.cachedStreams = streams;
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:streams andError:nil];
                    //}
                    
                } errorHandler:^(NSError *error) {
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
                }];
                
            }
        }
    });
}


- (void)createStream:(PYStream *)stream withCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYConnection *connection = [[NotesAppController sharedInstance] connection];
        if(!connection)
        {
            [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:[NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil]];
        }
        else
        {
            [connection createStream:stream withRequestType:PYRequestTypeSync successHandler:^(NSString *createdStreamId) {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:createdStreamId andError:nil];
            } errorHandler:^(NSError *error) {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
            }];
        }
    });
}

- (void)executeCompletionBlockOnMainQueue:(DataServiceCompletionBlock)completionBlock withObject:(id)object andError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock)
        {
            completionBlock(object, error);
        }
    });
}

- (void)saveEvent:(PYEvent *)event withCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    [self saveEventAsShortcut:event];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYConnection *connection = [[NotesAppController sharedInstance] connection];
        if(!connection)
        {
            NSError *error = [NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil];
            [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
        }
        else
        {
            [connection createEvent:event requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                NSLog(@"saved event id: %@",newEventId);
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:newEventId andError:nil];
            } errorHandler:^(NSError *error) {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
            }];
        }
    });
}

- (void)updateEvent:(PYEvent *)event withCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYConnection *connection = [[NotesAppController sharedInstance] connection];
        if(!connection)
        {
            [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:[NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil]];
        }
        else
        {
            [connection setModifiedEventAttributesObject:event forEventId:event.eventId requestType:PYRequestTypeSync successHandler:^(NSString *stoppedId) {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:event andError:nil];
            } errorHandler:^(NSError *error) {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
            }];
        }
    });
}

- (void)deleteEvent:(PYEvent *)event withCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYConnection *connection = [[NotesAppController sharedInstance] connection];
        if(!connection)
        {
            [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:[NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil]];
        }
        else
        {
            [connection trashOrDeleteEvent:event withRequestType:PYRequestTypeSync successHandler:^{
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:event andError:nil];
            } errorHandler:^(NSError *error) {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
            }];
        }
    });
}

- (void)fetchAllEventsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYConnection *connection = [[NotesAppController sharedInstance] connection];
        if(!connection)
        {
            [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:[NSError errorWithDomain:@"NotesApp - User is not logged in" code:100 userInfo:nil]];
        }
        else
        {
            [self fetchAllStreamsWithCompletionBlock:^(id object, NSError *error) {
                /**
                [connection getEventsWithRequestType:PYRequestTypeSync
                                              filter:nil
                                     gotCachedEvents:^(NSArray *cachedEventList) {
                                         if(![[NotesAppController sharedInstance] isOnline])
                                         {
                                             [self executeCompletionBlockOnMainQueue:completionBlock withObject:cachedEventList andError:nil];
                                             NSLog(@"OFFLINE");
                                         }
                                     } gotOnlineEvents:^(NSArray *onlineEventList, NSNumber *serverTime) {
                                         for(PYEvent *event in onlineEventList)
                                         {
                                             NSLog(@"event: %d",event.hasTmpId);
                                         }
                                         if([[NotesAppController sharedInstance] isOnline])
                                         {
                                             [self executeCompletionBlockOnMainQueue:completionBlock withObject:onlineEventList andError:nil];
                                             NSLog(@"ONLINE");
                                         }
                                     } onlineDiffWithCached:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
                                         NSLog(@"successHandler");
                                     } errorHandler:^(NSError *error) {
                                         [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
                                     }];
                 **/
                //                [connection getEventsWithRequestType:PYRequestTypeSync filter:nil successHandler:^(NSArray *eventList) {
                //                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:eventList andError:nil];
                //                } errorHandler:^(NSError *error) {
                //                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
                //                } shouldSyncAndCache:YES];
            }];
        }
    });
}

- (void)saveEventAsShortcut:(PYEvent *)event
{
    UserHistoryEntry *entry = [[UserHistoryEntry alloc] init];
    entry.streamId = event.streamId;
    entry.tags = [NSArray arrayWithArray:event.tags];
    entry.dataType = [self cellStyleForEvent:event];
    if(entry.dataType != CellStyleTypePhoto && entry.dataType != CellStyleTypeText)
    {
        NSArray *components = [event.type componentsSeparatedByString:@"/"];
        if([components count] > 1)
        {
            entry.measurementGroupName = [components objectAtIndex:0];
            entry.measurementTypeName = [components objectAtIndex:1];
        }
    }
    [[LRUManager sharedInstance] addUserHistoryEntry:entry];
}



- (NSInteger)cellStyleForEvent:(PYEvent *)event
{
    
    NSString *eventClassKey = event.pyType.classKey;
    if([eventClassKey isEqualToString:@"note"])
    {
        return CellStyleTypeText;
    }
    else if([eventClassKey isEqualToString:@"money"])
    {
        return CellStyleTypeMoney;
    }
    else if([eventClassKey isEqualToString:@"picture"])
    {
        return CellStyleTypePhoto;
    }
    else if ([event.pyType isNumerical]) {
        return CellStyleTypeMeasure;
    }
    //NSLog(@"<WARNING> cellStyleForEvent: unkown type:  %@ ", event);
    return CellStyleTypeUnkown;
}

- (EventDataType)eventDataTypeForEvent:(PYEvent *)event
{
    if ([event.pyType isNumerical]) {
        return EventDataTypeValueMeasure;
    }
    
    NSString *eventClassKey = event.pyType.classKey;
    if([eventClassKey isEqualToString:@"note"])
    {
        return EventDataTypeNote;
    }
    else if([eventClassKey isEqualToString:@"picture"])
    {
        return EventDataTypeImage;
    }
    NSLog(@"<WARNING> Dataservice.eventDataTypeForEvent: unkown type:  %@ ", event);
    return EventDataTypeNote;
}

- (void)invalidateStreamListCache
{
    self.cachedStreams = nil;
}

- (void)populateArray:(NSMutableArray *)array withStrems:(NSArray *)streams
{
    for(PYStream *stream in streams)
    {
        [array addObject:stream];
        if([stream.children count] > 0)
        {
            [self populateArray:array withStrems:stream.children];
        }
    }
}

@end
