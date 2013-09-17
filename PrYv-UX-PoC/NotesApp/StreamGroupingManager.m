//
//  ChannelGroupingManager.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "StreamGroupingManager.h"
#import <PryvApiKit/PryvApiKit.h>

@interface StreamGroupingManager ()

@property (nonatomic, strong) NSMutableArray *streams;

@end

@implementation StreamGroupingManager

- (id)init {
    self = [super init];
    if(self) {
        self.streams = [NSMutableArray array];
    }
    return self;
}

- (NSString*)titleForGroupAtIndex:(NSInteger)index {
    return [[_streams objectAtIndex:index] name];
}

- (NSInteger)numberOfGroups {
    return [_streams count];
}

- (NSInteger)numberOfItemsInGroupAtIndex:(NSInteger)index {
    return [[[_streams objectAtIndex:index] children] count];
}

- (NSString*)titleForItemInGroupAtIndex:(NSInteger)groupIndex andItemIndex:(NSInteger)itemIndex {
    return [[[[_streams objectAtIndex:groupIndex] children] objectAtIndex:itemIndex] name];
}

- (void)performGroupingWithCompletionBlock:(void (^)(void))completionHandler {
//    PYAccess *access = [[NotesAppController sharedInstance] access];
//    if(!access)
//    {
//        return;
//    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [access getAllChannelsWithRequestType:PYRequestTypeSync
//                            gotCachedChannels:^(NSArray *cachedChannelList) {
//            for (PYChannel *pyChannel in cachedChannelList)
//            {
//                Channel *channel = [[Channel alloc] initWithPYChannel:pyChannel];
//                NSMutableArray *folders = [NSMutableArray array];
//                [pyChannel getFoldersWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *foldersList) {
//                    for(PYFolder *pyFolder in foldersList) {
//                        Folder *folder = [[Folder alloc] initWithPYFolder:pyFolder];
//                        [folders addObject:folder];
//                    }
//                    channel.folders = [folders copy];
//                } errorHandler:^(NSError *error) {
//                    
//                } shouldSyncAndCache:YES];
//                
//                [_channels addObject:channel];
//            }
//            if(completionHandler) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completionHandler();
//                });
//            }
//        } gotOnlineChannels:^(NSArray *onlineChannelList) {
//            
//        } errorHandler:^(NSError *error) {
//            if(completionHandler) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    completionHandler();
//                });
//            }
//        }];
//    });
    
}

@end
