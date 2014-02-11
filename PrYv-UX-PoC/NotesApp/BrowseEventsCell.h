//
//  BrowseEventsCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/6/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserHistoryEntry;

@interface BrowseEventsCell : UITableViewCell

- (void)setupWithUserHistroyEntry:(UserHistoryEntry*)entry withStreams:(NSArray*)streams;

@end
