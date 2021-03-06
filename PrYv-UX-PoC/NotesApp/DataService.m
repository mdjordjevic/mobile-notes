//
//  DataService.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataService.h"
#import <PryvApiKit/PryvApiKit.h>
#import <PryvApiKit/PYClient.h>
#import "MeasurementSet.h"
#import "Stream.h"
#import "Event.h"
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"

#define kMeasurementSetsUrl @"http://pryv.github.io/event-types/extras.json"
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

- (void)fetchAllMeasurementSetsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    NSURL *measurementSetsURL = [NSURL URLWithString:kMeasurementSetsUrl];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:measurementSetsURL];
    [PYClient sendRequest:request withReqType:PYRequestTypeSync success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *sets = [NSMutableArray array];
        NSDictionary *setsJSON = [JSON objectForKey:@"sets"];
        for(NSString *setKey in [setsJSON allKeys])
        {
            NSDictionary *setDic = [setsJSON objectForKey:setKey];
            MeasurementSet *set = [[MeasurementSet alloc] initWithKey:setKey andDictionary:setDic];
            [sets addObject:set];
        }
        [self executeCompletionBlockOnMainQueue:completionBlock withObject:sets andError:nil];
    } failure:^(NSError *error) {
        [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
    }];
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
                    if(![[NotesAppController sharedInstance] isOnline])
                    {
                        NSMutableArray *streams = [NSMutableArray array];
                        [self populateArray:streams withStrems:cachedStreamsList];
                        [self executeCompletionBlockOnMainQueue:completionBlock withObject:streams andError:nil];
                    }
                    
                } gotOnlineStreams:^(NSArray *onlineStreamList) {
                    if([[NotesAppController sharedInstance] isOnline])
                    {
                        NSMutableArray *streams = [NSMutableArray array];
                        [self populateArray:streams withStrems:onlineStreamList];
                        self.cachedStreams = streams;
                        [self executeCompletionBlockOnMainQueue:completionBlock withObject:streams andError:nil];
                    }
                    
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
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if(!connection)
        {
            [userInfo setObject:[NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil] forKey:@"Error"];
            NSNotification *saveEventNotification = [NSNotification notificationWithName:kEventAddedNotification object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:saveEventNotification];
        }
        else
        {
            [connection createEvent:event requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                NSLog(@"saved event id: %@",newEventId);
                [userInfo setObject:newEventId forKey:@"EventId"];
                NSNotification *saveEventNotification = [NSNotification notificationWithName:kEventAddedNotification object:self userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotification:saveEventNotification];
            } errorHandler:^(NSError *error) {
                [userInfo setObject:error forKey:@"Error"];
                NSNotification *saveEventNotification = [NSNotification notificationWithName:kEventAddedNotification object:self userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotification:saveEventNotification];
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
                [connection getAllEventsWithRequestType:PYRequestTypeSync gotCachedEvents:^(NSArray *cachedEventList) {
                    if(![[NotesAppController sharedInstance] isOnline])
                    {
                        [self executeCompletionBlockOnMainQueue:completionBlock withObject:cachedEventList andError:nil];
                        NSLog(@"OFFLINE");
                    }
                } gotOnlineEvents:^(NSArray *onlineEventList) {
                    for(PYEvent *event in onlineEventList)
                    {
                        NSLog(@"event: %d",event.hasTmpId);
                    }
                    if([[NotesAppController sharedInstance] isOnline])
                    {
                        [self executeCompletionBlockOnMainQueue:completionBlock withObject:onlineEventList andError:nil];
                        NSLog(@"ONLINE");
                    }
                } successHandler:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
                    NSLog(@"successHandler");
                } errorHandler:^(NSError *error) {
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
                }];
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
    entry.dataType = [self dataTypeForEvent:event];
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

- (NSInteger)dataTypeForEvent:(PYEvent *)event
{
    NSArray *components = [event.type componentsSeparatedByString:@"/"];
    if([components count] < 2)
    {
        return CellStyleTypeText;
    }
    NSString *eventClass = [components objectAtIndex:0];
    if([eventClass isEqualToString:@"note"])
    {
        return CellStyleTypeText;
    }
    if([eventClass isEqualToString:@"mass"])
    {
        return CellStyleTypeMass;
    }
    if([eventClass isEqualToString:@"money"])
    {
        return CellStyleTypeMoney;
    }
    if([eventClass isEqualToString:@"length"])
    {
        return CellStyleTypeLength;
    }
    if([eventClass isEqualToString:@"picture"])
    {
        return CellStyleTypePhoto;
    }
    return CellStyleTypeLength;
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
