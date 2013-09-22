//
//  DataService.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataServiceCompletionBlock)(id object, NSError *error);

@interface DataService : NSObject

+ (DataService*)sharedInstance;
- (void)fetchAllMeasurementSetsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)fetchAllStreamsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)fetchAllEventsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)saveEvent:(PYEvent *)event withCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)updateEvent:(PYEvent *)event withCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)deleteEvent:(PYEvent *)event withCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)createStream:(PYStream*)stream withCompletionBlock:(DataServiceCompletionBlock)completionBlock;

- (NSInteger)dataTypeForEvent:(PYEvent*)event;
- (void)invalidateStreamListCache;


@end
