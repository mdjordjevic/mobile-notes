//
//  Channel.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "Channel.h"
#import <PryvApiKit/PryvApiKit.h>

@implementation Channel

- (id)initWithPYChannel:(PYChannel *)pyChannel {
    self = [super init];
    if(self) {
        self.pyChannel = pyChannel;
        self.channelId = [[pyChannel channelId] copy];
        self.channelName = [[pyChannel name] copy];
        self.folders = nil;
        self.events = [NSMutableArray array];
    }
    return self;
}

@end
