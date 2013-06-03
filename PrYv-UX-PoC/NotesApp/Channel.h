//
//  Channel.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PYChannel;

@interface Channel : NSObject

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) PYChannel *pyChannel;

- (id)initWithPYChannel:(PYChannel*)pyChannel;

@end
