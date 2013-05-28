//
//  ChannelGroupingManager.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "ChannelGroupingManager.h"
#import "Channel.h"
#import "Folder.h"
#import <PryvApiKit/PryvApiKit.h>

@interface ChannelGroupingManager ()

@property (nonatomic, strong) NSMutableArray *channels;

@end

@implementation ChannelGroupingManager

- (id)init {
    self = [super init];
    if(self) {
        self.channels = [NSMutableArray array];
    }
    return self;
}

- (NSString*)titleForGroupAtIndex:(NSInteger)index {
    return [[_channels objectAtIndex:index] channelName];
}

- (NSInteger)numberOfGroups {
    return [_channels count];
}

- (NSInteger)numberOfItemsInGroupAtIndex:(NSInteger)index {
    return [[[_channels objectAtIndex:index] folders] count];
}

- (NSString*)titleForItemInGroupAtIndex:(NSInteger)groupIndex andItemIndex:(NSInteger)itemIndex {
    return [[[[_channels objectAtIndex:groupIndex] folders] objectAtIndex:itemIndex] folderName];
}

- (void)performGroupingWithCompletionBlock:(void (^)(void))completionHandler {
    PYAccess *access = [[NotesAppController sharedInstance] access];
    if(!access)
    {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [access getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
            for (PYChannel *pyChannel in channelList)
            {
                Channel *channel = [[Channel alloc] initWithPYChannel:pyChannel];
                NSMutableArray *folders = [NSMutableArray array];
                [pyChannel getFoldersWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *folderList) {
                    for(PYFolder *pyFolder in folderList) {
                        Folder *folder = [[Folder alloc] initWithPYFolder:pyFolder];
                        [folders addObject:folder];
                    }
                    channel.folders = [folders copy];
                } errorHandler:^(NSError *error) {
                    
                }];
                
                [_channels addObject:channel];
            }
            if(completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler();
                });
            }
        } errorHandler:^(NSError *error) {
            if(completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler();
                });
            }
        }];
    });
    
}

@end
