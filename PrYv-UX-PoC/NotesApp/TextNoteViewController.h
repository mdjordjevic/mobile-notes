//
//  TextNoteViewController.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/3/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class UserHistoryEntry;

@interface TextNoteViewController : BaseViewController

@property (nonatomic, strong) UserHistoryEntry *entry;
@property (nonatomic, strong) PYEvent *event;

@end
