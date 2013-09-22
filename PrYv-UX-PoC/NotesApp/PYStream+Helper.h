//
//  PYStream+Helper.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 9/20/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PYStream (Helper)

- (PYStream*)parentStreamInList:(NSArray*)streamList;
- (NSString*)breadcrumbsInStreamList:(NSArray*)streamList;
+ (NSString*)breadcrumsForStreamId:(NSString*)streamId inStreamList:(NSArray*)streamList;

@end
