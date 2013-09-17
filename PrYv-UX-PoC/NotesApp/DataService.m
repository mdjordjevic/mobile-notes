//
//  DataService.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataService.h"
#import <PryvApiKit/PryvApiKit.h>
#import "MeasurementSet.h"
#import "Stream.h"
#import "Event.h"
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"

#define kMeasurementSetsUrl @"http://pryv.github.io/event-types/extras.json"
#define kChannelListCacheTimeout 60 * 60 //60 minutes

@interface DataService ()

@property (nonatomic, strong) NSArray *cachedStreams;
@property (nonatomic, strong) NSDate *lastStreamsUpdateTimestamp;

- (void)initObject;
- (void)executeCompletionBlockOnMainQueue:(DataServiceCompletionBlock)completionBlock withObject:(id)object andError:(NSError*)error;
- (void)saveEventAsShortcut:(PYEvent*)event;

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
            if(self.cachedStreams && fabs([self.lastStreamsUpdateTimestamp timeIntervalSinceNow]) < kChannelListCacheTimeout)
            {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:self.cachedStreams andError:nil];
            }
            else
            {
                [connection getAllStreamsWithRequestType:PYRequestTypeSync gotCachedStreams:^(NSArray *cachedStreamsList) {
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:cachedStreamsList andError:nil];
                } gotOnlineStreams:^(NSArray *onlineStreamList) {
                    self.cachedStreams = onlineStreamList;
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:onlineStreamList andError:nil];
                } errorHandler:^(NSError *error) {
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
                }];
                    
            }
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
            [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:[NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil]];
        }
        else
        {
            [connection createEvent:event requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                [self executeCompletionBlockOnMainQueue:completionBlock withObject:newEventId andError:nil];
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
                [connection getEventsWithRequestType:PYRequestTypeSync filter:nil successHandler:^(NSArray *eventList) {
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:eventList andError:nil];
                } errorHandler:^(NSError *error) {
                    [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
                } shouldSyncAndCache:YES];
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
    return CellStyleTypeLength;
}

@end
