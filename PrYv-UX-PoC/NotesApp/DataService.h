//
//  DataService.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FetchDataCompletionBlock)(id object, NSError *error);

@interface DataService : NSObject

+ (void)fetchAllMeasurementSetsWithCompletionBlock:(FetchDataCompletionBlock)completionBlock;
+ (void)fetchAllChannelsWithCompletionBlock:(FetchDataCompletionBlock)completionBlock;

@end
