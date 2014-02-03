//
//  EventDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@class PYEvent,UserHistoryEntry;

@interface EventDetailsViewController : UITableViewController

@property (nonatomic, strong) PYEvent *event;
@property (nonatomic, strong) NSArray *streams;
@property (nonatomic, strong) UserHistoryEntry *entry;
@property (nonatomic) BOOL isNewEvent;

- (BOOL)shouldAnimateViewController:(UIViewController*)vc;

@end
