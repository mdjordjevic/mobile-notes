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

#define kMeasurementSetsUrl @"http://pryv.github.io/event-types/event-types-extras.json"

@interface DataService ()

+ (void)executeCompletionBlockOnMainQueue:(FetchDataCompletionBlock)completionBlock withObject:(id)object andError:(NSError*)error;

@end

@implementation DataService

+ (void)fetchAllMeasurementSetsWithCompletionBlock:(FetchDataCompletionBlock)completionBlock
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

+ (void)fetchAllChannelsWithCompletionBlock:(FetchDataCompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PYAccess *access = [[NotesAppController sharedInstance] access];
        [access getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
            NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[channelList count]];
            for(PYChannel *pyChannel in channelList)
            {
                NSMutableArray *folders = [NSMutableArray array];
                [pyChannel getFoldersWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *folderList) {
                    for(PYFolder *pyFolder in folderList)
                    {
                        Folder *folder = [[Folder alloc] initWithPYFolder:pyFolder];
                        [folders addObject:folder];
                    }
                } errorHandler:^(NSError *error) {
                    
                }];
                Channel *channel = [[Channel alloc] initWithPYChannel:pyChannel];
                channel.folders = folders;
                [channels addObject:channel];
            }
            [DataService executeCompletionBlockOnMainQueue:completionBlock withObject:channels andError:nil];
        } errorHandler:^(NSError *error) {
            [DataService executeCompletionBlockOnMainQueue:completionBlock withObject:nil andError:error];
        }];
    });
    
}

+ (void)executeCompletionBlockOnMainQueue:(FetchDataCompletionBlock)completionBlock withObject:(id)object andError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock)
        {
            completionBlock(object, error);
        }
    });
}

@end
