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
- (void)populateStreamList:(NSMutableArray*)array withStreamsTree:(NSArray*)streams;

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
    [NotesAppController sharedConnectionWithID:nil
             noConnectionCompletionBlock:nil
                     withCompletionBlock:^(PYConnection *connection)
     {
         if(self.cachedStreams && fabs([self.lastStreamsUpdateTimestamp timeIntervalSinceNow]) < kStreamListCacheTimeout)
         {
             completionBlock(self.cachedStreams, nil);
         }
         else
         {
             [connection getAllStreamsWithRequestType:PYRequestTypeAsync gotCachedStreams:^(NSArray *cachedStreamsList) {
                 //if(![[NotesAppController sharedInstance] isOnline])
                 //{
                 NSMutableArray *streams = [NSMutableArray array] ;
                 [self populateStreamList:streams withStreamsTree:cachedStreamsList];
                 completionBlock(streams, nil);
                 //}
                 
             } gotOnlineStreams:^(NSArray *onlineStreamList) {
                 //if([[NotesAppController sharedInstance] isOnline])
                 //{
                 NSMutableArray *streams = [NSMutableArray array];
                 [self populateStreamList:streams withStreamsTree:onlineStreamList];
                 self.cachedStreams = streams;
                 [self executeCompletionBlockOnMainQueue:completionBlock withObject:streams andError:nil];
                 //}
                 
             } errorHandler:^(NSError *error) {
                 [self executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
             }];
             
         }
     }];
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

- (void)populateStreamList:(NSMutableArray *)array withStreamsTree:(NSArray *)streams
{
    for(PYStream *stream in streams)
    {
        [array addObject:stream];
        if([stream.children count] > 0)
        {
            [self populateStreamList:array withStreamsTree:stream.children];
        }
    }
}

@end
