//
//  PYStream+Helper.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYStream+Helper.h"

@implementation PYStream (Helper)

- (PYStream*)parentStreamInList:(NSArray *)streamList
{
    if(self.parentId)
    {
        for(PYStream* stream in streamList)
        {
            if([stream.streamId isEqualToString:self.parentId])
            {
                return stream;
            }
        }
    }
    return nil;
}

- (NSString*)breadcrumbsInStreamList:(NSArray *)streamList
{
    PYStream *parent = [self parentStreamInList:streamList];
    if(parent)
    {
        NSString *breadcrumb = [parent breadcrumbsInStreamList:streamList];
        if([breadcrumb length] > 0)
        {
            return [[breadcrumb stringByAppendingString:@"/"] stringByAppendingString:self.name];
        }
        else
        {
            return self.name;
        }
    }
    return self.name;
}

+ (NSString*)breadcrumsForStreamId:(NSString *)streamId inStreamList:(NSArray *)streamList
{
    for(PYStream *stream in streamList)
    {
        if([stream.streamId isEqualToString:streamId])
        {
            return [stream breadcrumbsInStreamList:streamList];
        }
    }
    return streamId;
}

@end
