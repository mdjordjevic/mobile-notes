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
- (void)fetchAllChannelsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)saveEvent:(PYEvent*)event inChannel:(PYChannel*)channel withCompletionBlock:(DataServiceCompletionBlock)completionBlock;
- (void)fetchAllEventsWithCompletionBlock:(DataServiceCompletionBlock)completionBlock;


@end
