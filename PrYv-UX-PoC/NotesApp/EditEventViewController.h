//
//  EditEventViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/29/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseEventPreviewElement.h"
#import "Channel.h"
#import "Folder.h"

@class UserHistoryEntry;

@interface EditEventViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) BaseEventPreviewElement *eventElement;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) Folder *folder;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) UserHistoryEntry *entry;

@end
