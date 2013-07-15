//
//  DataService.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "DataService.h"
#import <PryvApiKit/PYClient.h>
#import "MeasurementSet.h"
#import "Channel.h"
#import "Folder.h"
#import "Event.h"
#import "LRUManager.h"
#import "UserHistoryEntry.h"
#import "CellStyleModel.h"

#define kMeasurementSetsUrl @"http://pryv.github.io/event-types/event-types-extras.json"
#define kChannelListCacheTimeout 60 * 60 //60 minutes

@interface DataService ()

@property (nonatomic, strong) NSArray *cachedChannels;
@property (nonatomic, strong) NSDate *lastChannelsUpdateTimestamp;

- (void)initObject;
- (void)executeCompletionBlockOnMainQueue:(DataServiceCompletionBlock)completionBlock withObject:(id)object andError:(NSError*)error;
- (void)saveEventAsShortcut:(PYEvent*)event;
- (NSInteger)dataTypeForEvent:(PYEvent*)event;

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
        NSDictionary *localizedNamesJSON = [JSON objectForKey:@"localizedNames"];
        for(NSString *setKey in [setsJSON allKeys])
        {
            NSDictionary *setDic = [setsJSON objectForKey:setKey];
            MeasurementSet *set = [[MeasurementSet alloc] initWithKey:setKey andDictionary:setDic andLocalizedNames:localizedNamesJSON];
            [sets addObject:set];
        }
        if(completionBlock)
        {
            completionBlock(sets, nil);
        }
    } failure:^(NSError *error) {
        if(completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
}

- (void)fetchAllChannelsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYAccess *access = [[NotesAppController sharedInstance] access];
        if(!access)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,[NSError errorWithDomain:@"Connection error" code:-100 userInfo:nil]);
            });
        }
        else
        {
            if(self.cachedChannels && fabs([self.lastChannelsUpdateTimestamp timeIntervalSinceNow]) < kChannelListCacheTimeout)
            {
                [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:self.cachedChannels andError:nil];
            }
            else
            {
                [access getAllChannelsWithRequestType:PYRequestTypeSync gotCachedChannels:^(NSArray *cachedChannelList) {
                    
                } gotOnlineChannels:^(NSArray *onlineChannelList) {
                    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[onlineChannelList count]];
                    for(PYChannel *pyChannel in onlineChannelList)
                    {
                        NSMutableArray *folders = [NSMutableArray array];
                        [pyChannel getFoldersWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *foldersList) {
                            for(PYFolder *pyFolder in foldersList)
                            {
                                Folder *folder = [[Folder alloc] initWithPYFolder:pyFolder];
                                [folders addObject:folder];
                            }
                        } errorHandler:^(NSError *error) {
                            
                        } shouldSyncAndCache:YES];
                        Channel *channel = [[Channel alloc] initWithPYChannel:pyChannel];
                        channel.folders = folders;
                        [channels addObject:channel];
                    }
                    self.cachedChannels = channels;
                    [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:channels andError:nil];
                } errorHandler:^(NSError *error) {
                    [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
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

- (void)saveEvent:(PYEvent *)event inChannel:(PYChannel *)channel withCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    [self saveEventAsShortcut:event];
    [channel createEvent:event requestType:PYRequestTypeAsync successHandler:^(NSString *newEventId, NSString *stoppedId) {
        [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:newEventId andError:nil];
    } errorHandler:^(NSError *error) {
        [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
    }];
}

- (void)fetchAllEventsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYAccess *access = [[NotesAppController sharedInstance] access];
        if(!access)
        {
            [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:[NSError errorWithDomain:@"NotesApp - User is not logged in" code:100 userInfo:nil]];
        }
        else
        {
            __block BOOL cachedChannalsReceived = NO;
            void (^channelsBlock)(NSArray* receivedChannels) = ^(NSArray *receivedChannels){
                NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[receivedChannels count]];
                for(PYChannel *pyChannel in receivedChannels)
                {
                    NSMutableArray *events = [NSMutableArray array];
                    [pyChannel getAllEventsWithRequestType:PYRequestTypeSync gotCachedEvents:^(NSArray *cachedEventList) {
                        
                    } gotOnlineEvents:^(NSArray *onlineEventList) {
                        [events addObjectsFromArray:onlineEventList];
                    } successHandler:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
                        
                    } errorHandler:^(NSError *error) {
                        
                    }];
                    Channel *channel = [[Channel alloc] initWithPYChannel:pyChannel];
                    channel.events = events;
                    [channels addObject:channel];
                }
                [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:channels andError:nil];
            };
            [access getAllChannelsWithRequestType:PYRequestTypeSync gotCachedChannels:^(NSArray *cachedChannelList) {
                if(cachedChannelList && [cachedChannelList count] > 0)
                {
                    cachedChannalsReceived = YES;
                }
                channelsBlock(cachedChannelList);
            } gotOnlineChannels:^(NSArray *onlineChannelList) {
                if(!cachedChannalsReceived)
                {
                    channelsBlock(onlineChannelList);
                }
            } errorHandler:^(NSError *error) {
                [[DataService sharedInstance] executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
            }];
        }
        
    });
}

- (void)saveEventAsShortcut:(PYEvent *)event
{
    UserHistoryEntry *entry = [[UserHistoryEntry alloc] init];
    entry.channelId = event.channelId;
    entry.folderId = event.folderId;
    entry.tags = [NSArray arrayWithArray:event.tags];
    entry.dataType = [self dataTypeForEvent:event];
    [[LRUManager sharedInstance] addUserHistoryEntry:entry];
}

- (NSInteger)dataTypeForEvent:(PYEvent *)event
{
    if([event.eventClass isEqualToString:@"note"])
    {
        return CellStyleTypeText;
    }
    if([event.eventClass isEqualToString:@"mass"])
    {
        return CellStyleTypeMass;
    }
    if([event.eventClass isEqualToString:@"money"])
    {
        return CellStyleTypeMoney;
    }
    if([event.eventClass isEqualToString:@"length"])
    {
        return CellStyleTypeLength;
    }
    return CellStyleTypeLength;
}

@end
