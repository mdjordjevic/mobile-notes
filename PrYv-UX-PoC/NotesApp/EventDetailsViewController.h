//
//  EventDetailsViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 1/21/14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BaseViewController.h"

@class PYEvent;

@interface EventDetailsViewController : UITableViewController

@property (nonatomic, strong) PYEvent *event;
@property (nonatomic, strong) NSArray *streams;

@end
