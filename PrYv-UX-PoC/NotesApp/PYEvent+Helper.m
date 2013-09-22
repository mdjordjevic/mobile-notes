//
//  PYEvent+Helper.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYEvent+Helper.h"
#import "PYStream+Helper.h"

@implementation PYEvent (Helper)

- (NSString*)eventBreadcrumbsForStreamsList:(NSArray *)streams
{
    NSString *streamId = self.streamId;
    if(streamId)
    {
        for(PYStream* stream in streams)
        {
            if([stream.streamId isEqualToString:streamId])
            {
                return [stream breadcrumbsInStreamList:streams];
            }
        }
    }
    return nil;
}

@end
